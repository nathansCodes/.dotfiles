local wibox = require("wibox")

--- A simple button without any fancy animations
return function(args)
    local widget = args[1] or args.widget
    if widget ~= nil and not widget.is_widget then
        widget = wibox.widget(widget)
    end

    local button = wibox.widget {
        widget = wibox.container.background,
        shape = args.shape,
        bg = args.bg,
        fg = args.fg,
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

        -- make manual layouts work
        point = args.point,
    }

    local old_cursor, old_wibox

    button:connect_signal("mouse::enter", function()
        local w = mouse.current_wibox
        if w and (args.change_cursor == nil or args.change_cursor == true) then
            old_cursor, old_wibox = w.cursor, w
            w.cursor = "hand1"
        end

        if type(args.on_mouse_enter) == "function" then
            args.on_mouse_enter(button, widget)
        end
    end)

    button:connect_signal("mouse::leave", function()
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end

        if type(args.on_mouse_leave) == "function" then
            args.on_mouse_leave(button, widget)
        end
    end)

    button:connect_signal("button::press", function(self, lx, ly, b, find_widgets_result)
        self.pressed = true

        if type(args.on_press) == "function" then
            args.on_press(self, widget, lx, ly, b, find_widgets_result)
        end
    end)

    button:connect_signal("button::release", function(self, lx, ly, b, find_widgets_result)
        self.pressed = false

        if type(args.on_release) == "function" then
            args.on_release(self, widget, lx, ly, b, find_widgets_result)
        end
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

    return button
end
