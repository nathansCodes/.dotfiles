local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

_G.dont_disturb = false

return function(size)
    local icon = wibox.widget {
        widget = wibox.widget.textbox,
        text = '',
        font = beautiful.font .. " Regular " .. (size or dpi(18)),
        halign = "center",
    }

    local widget = wibox.widget {
        id = "icon_bg",
        widget = wibox.container.background,
        shape = gears.shape.circle,
        bg = beautiful.button_bg_off,
        {
            widget = wibox.container.place,
            valgin = "center",
            halgin = "center",
            content_fill_horizontal = true,
            {
                id = "margin",
                widget = wibox.container.margin,
                right = dpi(10),
                icon,
            },
        }
    }

    widget:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            if _G.dont_disturb == true then
                _G.dont_disturb = false
                icon:set_markup_silently("")
                widget.bg = beautiful.button_bg_off
                widget.fg = beautiful.fg_normal
                widget:get_children_by_id("margin")[1].right = 10
            else
                _G.dont_disturb = true
                icon:set_markup_silently("")
                widget.bg = beautiful.button_bg_on
                widget.fg = beautiful.bg_focus
                widget:get_children_by_id("margin")[1].right = 18
            end
        end
    end)

    local old_cursor, old_wibox

    widget:connect_signal( 'mouse::enter', function()
        local w = mouse.current_wibox
        if w then
            old_cursor, old_wibox = w.cursor, w
            w.cursor = 'hand1'
        end
    end)

    widget:connect_signal( 'mouse::leave', function()
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)

    return widget
end
