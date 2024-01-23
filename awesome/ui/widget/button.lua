local wibox = require("wibox")
local naughty = require("naughty")
local awful = require("awful")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local rubato = require("modules.rubato")

local helpers = require("helpers")

return function(args)
    args.bg_off = args.bg_off or args.bg
    args.bg_on = args.bg_on or args.bg
    args.fg_off = args.fg_off or args.fg
    args.fg_on = args.fg_on or args.fg

    args.margins = args.margins or 0
    args.top_margin = args.top_margin or 0
    args.bottom_margin = args.bottom_margin or 0
    args.left_margin = args.left_margin or 0
    args.right_margin = args.right_margin or 0

    args.hover_effect = not (args.hover_effect == false)
    args.shape = args.shape or helpers.ui.rrect(10)
    args.on = args.on or false

    args.on_mouse_enter = args.on_mouse_enter or function(_,_) end
    args.on_mouse_leave = args.on_mouse_leave or function(_,_) end
    args.on_press = args.on_press or function(_,_,_,_,_,_,_,_,_) end
    args.on_release = args.on_release or function(_,_,_,_,_,_,_,_,_) end

    local widget = args.widget or nil

    if widget ~= nil and not widget.is_widget then
        widget = wibox.widget(widget)
    end

    -- handle nil as true
    if args.animate == false then
        args.distance = 0
    elseif args.distance == nil then
        args.distance = 3
    end

    local bg = wibox.widget {
        widget = wibox.container.background,
        shape = args.shape,
        bg = args.on and args.bg_on or args.bg_off,
        fg = args.on and args.fg_on or args.fg_off,
        widget,
    }

    local hover_effect = wibox.widget {
        widget = wibox.container.background,
        shape = args.shape,
        bg = beautiful.fg_normal,
        opacity = 0,
    }

    local container = wibox.widget {
        widget = wibox.container.margin,
        margins = args.margins,
        top = args.top_margin,
        bottom = args.bottom_margin,
        left = args.left_margin,
        right = args.right_margin,
        forced_width = args.width or nil,
        forced_height = args.height or nil,
        {
            layout = wibox.layout.stack,
            bg,
            hover_effect,
        },

        on = args.on or false,

        -- make manual layouts work
        point = args.point,
    }

    local hover_effect_anim = rubato.timed {
        duration = 0.2,
        subscribed = function(pos)
            hover_effect:set_opacity(pos)
        end,
    }

    local old_cursor, old_wibox

    container:connect_signal("mouse::enter", function()
        hover_effect_anim.target = args.hover_effect and 0.2 or 0

        local w = mouse.current_wibox
        if w and (args.change_cursor == nil or args.change_cursor == true) then
            old_cursor, old_wibox = w.cursor, w
            w.cursor = "hand1"
        end

        args.on_mouse_enter(container, widget)
    end)

    container:connect_signal("mouse::leave", function()
        hover_effect_anim.target = 0

        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end

        args.on_mouse_leave(container, widget)
    end)

    container:connect_signal("button::press", function(self, lx, ly, button, find_widgets_result)
        hover_effect_anim.target = args.hover_effect and 0.25 or 0
        self.pressed = true

        args.on_press(self, widget, lx, ly, button, find_widgets_result)
    end)

    container:connect_signal("button::release", function(self, lx, ly, button, find_widgets_result)
        hover_effect_anim.target = args.hover_effect and 0.2 or 0
        self.pressed = false

        self:toggle()

        args.on_release(self, widget, lx, ly, button, find_widgets_result)
    end)

    function container:set_on_press(func)
        if type(func) == "function" then
            args.on_press = func
        end
    end

    function container:set_on_release(func)
        if type(func) == "function" then
            args.on_release = func
        end
    end

    function container:set_on_mouse_enter(func)
        if type(func) == "function" then
            args.on_mouse_enter = func
        end
    end

    function container:set_on_mouse_leave(func)
        if type(func) == "function" then
            args.on_mouse_leave = func
        end
    end

    function container:get_children_by_id(id)
        return widget ~= nil and widget:get_children_by_id(id) or nil
    end

    function container:get_widget()
        return widget
    end

    function container:set_bg(color)
        bg:set_bg(color)
    end

    function container:set_fg(color)
        bg:set_fg(color)
    end

    function container:turn_on()
        self.on = true
        bg:set_bg(args.bg_on)
        bg:set_fg(args.fg_on)
    end

    function container:turn_off()
        self.on = false
        bg:set_bg(args.bg_off)
        bg:set_fg(args.fg_off)
    end

    function container:toggle()
        if self.on == true then
            self:turn_off()
        else
            self:turn_on()
        end
    end

    local mt = getmetatable(container)
    --setmetatable(container, {})
    local ___index = mt.__index
    local ___newindex = mt.__newindex
    function mt:__index(key)
        --autogenerate getters and setters
        if key:match("set_widget_") then return function(_, v)
            if widget ~= nil then
                widget[key:sub(5)] = v
            end
        end end
        if key:match("get_widget_") then return function()
            return widget ~= nil and widget[key:sub(5)] or nil
        end end

        if key:match("set_") then return function(_, v) args[key:sub(5)] = v end end
        if key:match("get_") then return function() return args[key:sub(5)] end end

        --otherwise pass to widget.base
        return ___index(self, key)
    end
    function mt:__newindex(key, value)
        if args[key] then args[key] = value; return end
        return ___newindex(self, key, value)
    end

    local cmt = setmetatable(container, mt)

    return cmt
end
