local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local rubato = require("rubato")

return function(widget)
    widget = wibox.widget(widget)
    local container = wibox.widget {
        widget = wibox.container.margin,
        widget,
    }

    local stop_animation = false
    local animator = rubato.timed {
        duration = 0.1,
        subscribed = function(pos)
            if not widget.top and not widget.right
                    and not widget.bottom and not widget.left then
                container.margins = stop_animation and 0 or dpi(pos)
            else
                if widget.top == true then
                    container.top = stop_animation and 0 or dpi(pos)
                end
                if widget.right == true then
                    container.right = stop_animation and 0 or dpi(pos)
                end
                if widget.bottom == true then
                    container.bottom = stop_animation and 0 or dpi(pos)
                end
                if widget.left == true then
                    container.left = stop_animation and 0 or dpi(pos)
                end
            end
        end,
    }

    local old_cursor, old_wibox
    local hovered = false

    widget:connect_signal( 'mouse::enter', function()
        animator.target = -((2/3) * (widget.distance or 6))
        local w = mouse.current_wibox
        if w and (widget.change_cursor == nil or widget.change_cursor == true) then
            old_cursor, old_wibox = w.cursor, w
            w.cursor = 'hand1'
        end
        hovered = true
    end)

    widget:connect_signal( 'mouse::leave', function()
        animator.target = 0
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
        hovered = false
    end)

    widget:connect_signal("button::press", function(self, _, _, button)
        if button == 1 then
            animator.target = (widget.distance or 6)/3
            container.pressed = true
        end
    end)

    widget:connect_signal("button::release", function(self, c3, _, button)
        if button == 1 then
            animator.target = -((2/3) * (widget.distance or 6))
            container.pressed = false
            if widget.callback == nil then return end
            widget.callback(self, c3, _, button)
        end
    end)

    function container:set_bg(bg) widget.bg = bg end
    function container:set_fg(fg) widget.fg = fg end

    function container:stop_animations()
        stop_animation = true
        container.margins = 0
    end
    function container:continue_animations()
        stop_animation = false
        if not hovered then animator.pos = 0 end
    end

    return container
end
