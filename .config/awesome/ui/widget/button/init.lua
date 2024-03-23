local wibox = require("wibox")
local beautiful = require("beautiful")

local color = require("modules.lua-color")
local rubato = require("modules.rubato")

local helpers = require("helpers")

local button = { simple = require("ui.widget.button.simple") }

function button.new(args)
    args.margins = args.margins or 0
    args.top = args.top or nil
    args.bottom = args.bottom or nil
    args.left = args.left or nil
    args.right = args.right or nil
    args.bg = args.bg or beautiful.base
    args.fg = args.fg or beautiful.text

    args.hover_on_mouse_enter = not (args.hover_on_mouse_enter == false)
    args.shape = args.shape or helpers.ui.rrect(10)

    args.on_mouse_enter = args.on_mouse_enter or function(_,_) end
    args.on_mouse_leave = args.on_mouse_leave or function(_,_) end
    args.on_press = args.on_press or function(_,_,_,_,_,_,_,_,_) end
    args.on_release = args.on_release or function(_,_,_,_,_,_,_,_,_) end

    local widget = args.widget or args[1] or nil

    if widget ~= nil and not widget.is_widget then
        widget = wibox.widget(widget)
    end

    if not args.hover_bg then
        args.hover_bg = color(args.bg)
        args.hover_bg = color(beautiful.highlight_low)
    elseif args.hover_bg == "lighten" then
        args.hover_bg = color(args.bg)
        args.hover_bg = args.hover_bg:mix(args.lighten_with or beautiful.text, 0.2)
    elseif args.hover_bg == "darken" then
        args.hover_bg = color(args.bg)
        args.hover_bg:mix(args.darken_with or beautiful.base, 0.2)
    elseif type(args.hover_bg) == "string" then
        args.hover_bg = color(args.hover_bg)
    elseif not color.isColor(args.hover_bg) then
        args.hover_bg = nil
    end
    if args.hover_fg and type(args.hover_fg) == "string" then
        args.hover_fg = color(args.hover_fg)
    elseif not color.isColor(args.hover_fg) then
        args.hover_fg = nil
    end

    local button = wibox.widget {
        widget = wibox.container.background,
        shape = args.shape,
        bg = args.bg,
        fg = args.fg,
        border_color = args.border_color,
        border_width = args.border_width,
        forced_width = args.width or nil,
        forced_height = args.height or nil,
        {
            widget = wibox.container.margin,
            margins = args.margins,
            top = args.top,
            bottom = args.bottom,
            left = args.left,
            right = args.right,
            widget,
        },

        -- make ids and manual layouts work
        id = args.id,
        point = args.point,
    }

    button._set_bg = button.set_bg
    function button:set_bg(color)
        self:_set_bg(color)
        args.bg = color
    end

    button._set_fg = button.set_fg
    function button:set_fg(color)
        self:_set_fg(color)
        args.fg = color
    end

    -- make lua stop complaining
    ---@type table|nil
    local animator = rubato.timed {
        duration = 0.2,
        easing = rubato.quadratic,
        subscribed = function(pos)
            if args.hover_bg then
                local col = color(args.bg):mix(args.hover_bg, pos)
                button:_set_bg(col:tostring("#ffffffff"))
            end
            if args.hover_fg then
                local col = color(args.fg):mix(args.hover_fg, pos)
                button:_set_fg(col:tostring("#ffffffff"))
            end
        end,
    }

    local old_cursor, old_wibox

    button:connect_signal("mouse::enter", function()
        if args.hover_on_mouse_enter then
            animator.target = 1
        end

        local w = mouse.current_wibox
        if w and (args.change_cursor == nil or args.change_cursor == true) then
            old_cursor, old_wibox = w.cursor, w
            w.cursor = "hand1"
        end

        args.on_mouse_enter(button, widget)
    end)

    function button:hover()
        if animator ~= nil then
            animator.target = 1
        end
    end

    function button:unhover()
        if animator ~= nil then
            animator.target = 0
        end
    end

    function button:get_children_by_id(id)
        if id == args.id then return { self } end
        return widget and widget:get_children_by_id(id) or {}
    end

    button:connect_signal("mouse::leave", function()
        if args.hover_on_mouse_enter then
            animator.target = 0
        end

        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end

        args.on_mouse_leave(button, widget)
    end)

    button:connect_signal("button::press", function(self, lx, ly, b, find_widgets_result)
        animator.target = 0.8
        self.pressed = true

        args.on_press(self, widget, lx, ly, b, find_widgets_result)
    end)

    button:connect_signal("button::release", function(self, lx, ly, b, find_widgets_result)
        animator.target = 1
        self.pressed = false

        args.on_release(self, widget, lx, ly, b, find_widgets_result)
    end)

    function button:set_on_press(func)
        if type(func) == "function" then
            args.on_press = func
        end
    end

    function button:set_on_release(func)
        if type(func) == "function" then
            args.on_release = func
        end
    end

    function button:set_on_mouse_enter(func)
        if type(func) == "function" then
            args.on_mouse_enter = func
        end
    end

    function button:set_on_mouse_leave(func)
        if type(func) == "function" then
            args.on_mouse_leave = func
        end
    end

    function button:get_widget()
        return widget
    end

    local mt = getmetatable(button)
    --setmetatable(container, {})
    local ___index = mt.__index
    local ___newindex = mt.__newindex
    function mt:__index(key)
        --autogenerate getters and setters
        if key:match("set_") then return function(_, v) args[key:sub(5)] = v end end
        if key:match("get_") then return function() return args[key:sub(5)] end end

        --otherwise pass to widget.base
        return ___index(self, key)
    end
    function mt:__newindex(key, value)
        if args[key] then args[key] = value; return end
        return ___newindex(self, key, value)
    end

    return setmetatable(button, mt)
end

return setmetatable(button, { __call = function(_, ...) return button.new(...) end })
