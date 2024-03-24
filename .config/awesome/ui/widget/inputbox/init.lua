local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = require("beautiful").xresources.apply_dpi
local base = wibox.widget.base

local color = require("modules.lua-color")
local rubato = require("modules.rubato")

local helpers = require("helpers")

local function remove_cursor(markup)
    if type(markup) ~= "string" then return end
    return markup:gsub("(.*)<span .-> </span>$", "%1")
end

local module = {
    checkers = require(... .. ".checkers"),
    parsers = require(... .. ".parsers"),
}

-- workaraound to get lsps to not scream that there is no wibox.container.background
---@class wibox.container.background
---@field connect_signal function
---@field emit_signal function
---@field set_bg function
---@field set_fg function

---@class inputbox: wibox.container.background
---@field private _private table
---@field textbox table
---@field children table
local inputbox = {}

-- slightly stolen from yoru
function inputbox:start()
    if self.is_running then return end

    local function retry() self:retry() end
    local text = self._private.default_text
    if self._private.continuous_input then
        text = self.textbox.text
    end
    self._private.start_callback()
    awful.prompt.run {
        bg_cursor = beautiful.text,
        fg_cursor = self._private.background,
        text = text,
        font = self._private.font,
        textbox = self.textbox,
        hooks = {
            -- rxyhn, why triple dash???
            --- Fix for Control+Delete crashing the keygrabber
            { { "Control" }, "Delete", retry, },
            { { "Mod4", "Control" }, "r", retry, },
            --- Custom escape behaviour: Do not cancel input with Escape
            --- Instead, this will just clear any input received so far.
            self._private.retry_on_escape and { {}, "Escape", retry } or nil,
        },
        changed_callback = function(input)
            if self._private.live_update then
                local status = self._private.check_input(input)
                if type(status) ~= "boolean" then return end

                if status then
                    self:set_fg(self._private.fg)
                else
                    self:set_fg(beautiful.error)
                end
            end
        end,
        done_callback = function()
            self.is_running = false
            if self._private.continuous_input and self.textbox.text == "" then
                self:reset_input()
            end
            self._private.done_callback()
        end,
        keypressed_callback = self._private.keypressed_callback,
        keyreleased_callback = self._private.keyreleased_callback,
        exe_callback = function(input)
            -- make it not crash when pressing enter without any input
            if input == "" then
                self:reset_input()
                self:start()
                return
            end
            self._private.exe_callback(input)
            local status = self._private.check_input(input)
            if type(status) ~= "boolean" then return end
            --- Check input
            if status then
                --- YAY
                if type(self._private.success_callback) == "function" then
                    self._private.success_callback(input)
                end
                self:emit_signal("success")
                if self._private.continuous_input then
                    self.textbox:_set_markup(self._private.parse_input(input))
                end
            else
                --- NAY
                self:fail()
                self:emit_signal("fail")
                self.textbox:_set_markup(self._private.default_text or self._private.placeholder)
            end
        end,
    }
    self.is_running = true
end


--- Resets the input, either making it blank or restoring
--- it to the placeholder or default text
function inputbox:reset_input()
    if self._private.placeholder ~= false then
        self.textbox.placeholder = true
        self.textbox:set_markup("")
    end
    if type(self._private.default_text) == "string"
        and self._private.continuous_input then
        self.textbox:set_markup(self._private.default_text)
    end
end

--- Force stops the inputbox without checking what has been typed.
--- Use `:confirm` instead if you actually want to use the typed input
function inputbox:stop()
    awful.keygrabber.stop()
    self:reset_input()
    self.is_running = false
end

--- Will try to confirm the input. Essentially the same as pressing Enter.
--- Won't do anything if the inputbox is not active
function inputbox:confirm()
    if not self.is_running then return end
    -- ctrl+j because enter doesn't work
    awful.keyboard.emulate_key_combination({"Control"}, "j")
end

--- Restart the inputbox. Stops and starts again. Does nothing if not running
function inputbox:retry()
    if self.is_running then
        self:stop()
        self:start()
    end
end

---@private
function inputbox:fail(input)
    self._private.fail_flash.target = 1
    self._private.fail_callback(input)

    self.is_running = false
    if self._private.retry_on_fail then
        self:reset_input()
        self:start()
    end
end

--- Override the text that has/has not been typed
function inputbox:set_text(text)
    if type(text) ~= "string" then return end
    if self.is_running then
        self:stop()
        self.textbox:_set_markup(text)

        -- set continuous_input to true and then back so that it keeps the text
        local tmp = self._private.continuous_input
        self._private.continuous_input = true
        self:start()
        self._private.continuous_input = tmp
    else
        self.textbox:_set_markup(text)
    end
end

local function make_textbox(args)
    local textbox = wibox.widget {
        widget = wibox.widget.textbox,
        font = args.font,
        halign = "left",
        valign = "center",
        text = args.default_text or args.placeholder
    }

    -- make placeholders work by overriding set_markup
    -- this works, because awful.prompt keeps track of an internal input var
    -- instead of using the textbox as the buffer
    textbox._set_markup = textbox.set_markup
    function textbox:set_markup(markup)
        if type(markup) ~= "string" then
            return
        end
        local raw_markup = remove_cursor(markup) or ""
        local show_placeholder = (raw_markup:len() < 1 and args.placeholder)
            or (raw_markup == args.placeholder and self.placeholder_shown)
        if show_placeholder then
            self:set_font(args.font)
            self:_set_markup(args.placeholder)
            self.placeholder_shown = true
        else
            if args.hide_input then
                -- don't actually show the input
                self:set_font("Symbols Nerd Font 11")
                self:_set_markup(string.rep("", raw_markup:len()))
                -- self:_set_markup(raw_markup)
                -- self:_set_markup(m)
            else
                self:set_font(args.font)
                self:_set_markup(markup)
            end
            self.placeholder_shown = false
        end
    end

    return textbox
end

local defaults = {
    ---@type string|false
    default_text = false,
    font = beautiful.font .. "Regular 11",
    ---@type string|false
    placeholder = "Enter Text...",
    exe_callback = function(_,_) end,
    fail_flash_hook = function(_,_,_) end,
    keypressed_callback = function(_,_,_) end,
    keyreleased_callback = function(_,_,_) end,
    success_callback = function(_,_) end,
    start_callback = function() end,
    done_callback = function() end,
    fail_callback = function(_,_) end,
    check_input = function(_,_) return true end,
    parse_input = function(text) return text end,
    hide_input = false,
    live_update = false,
    retry_on_fail = false,
    retry_on_escape = false,
    continuous_input = false,
}

--- Creates a new inputbox
---@param args table
---@return inputbox
function module.new(args)
    local widget = base.make_widget(nil, nil, {
        enable_properties = true,
    })

    gears.table.crush(widget, wibox.container.background, true)

    widget:set_bg(args.bg or beautiful.overlay)
    widget:set_fg(args.fg or beautiful.text)
    widget:set_forced_height(args.forced_height or dpi(40))
    widget:set_forced_width(args.forced_width)
    widget:set_shape(args.shape or helpers.ui.rrect(6))

    -- set args and create setters and getters
    for key, default in pairs(defaults) do
        widget._private[key] = args[key] or default
        widget["set_"..key] = function(s, value)
            if type(value) ~= type(default) then return end
            s._private[key] = value
        end
        widget["get_"..key] = function(s)
            return s._private[key]
        end
    end

    if args.placeholder == false then
        widget._private.placeholder = false
    end

    widget:set_forced_height(args.forced_height or dpi(40))
    widget:set_forced_width(args.forced_width)

    widget:set_widget {
        widget = wibox.container.margin,
        margins = args.margins or dpi(5),
        left = args.left,
        right = args.right,
        top = args.top,
        bottom = args.bottom,
        make_textbox(widget._private),
    }

    widget.textbox = widget.children[1].children[1]

    gears.table.crush(widget, inputbox, true)

    widget:connect_signal("button::release", function(_, _, _, b)
        if b == 1 and not awful.keygrabber.is_running then
            widget:start()
        end
    end)

    local fail_color = color(beautiful.error)
    widget._private.fail_flash = rubato.timed {
        duration = 0.7,
        intro = 0.35,
        outro = 0.35,
        awestore_compat = true,
        subscribed = function(pos)
            local bg = color(widget._private.background)
            local col = bg:mix(fail_color, math.min(1, math.max(0, pos)))
            col = col:tostring()
            widget:set_border_color(col)
            widget:set_border_width(pos*2)
            widget._private.fail_flash_hook(widget, pos, col)
        end
    }

    widget._private.fail_flash.ended:subscribe(function()
        if widget._private.fail_flash.pos == 1 then
            widget._private.fail_flash.target = 0
        end
    end)

    return widget
end

return setmetatable(module, { __call = function(_, ...) return module.new(...) end })
