local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

require("helpers.widget")

_G.dont_disturb = false

return function(size)
    local icon = wibox.widget {
		{
			id = 'icon',
			text = '',
			widget = wibox.widget.textbox,
            font = beautiful.font .. " Regular " .. (size or 18) - 6,
		},
        resize = true,
		layout = wibox.layout.align.horizontal,
        expand = "none",
    }


    local widget = wibox.widget {
        id = "icon_bg",
        widget = wibox.container.background,
        shape = gears.shape.circle,
        bg = beautiful.button_bg_off,
        {
            layout = wibox.layout.align.vertical,
            forced_height = dpi(size),
            forced_width = dpi(size),
            margins = dpi(0),
            expand = "outside",
            nil,
            {
                id = "icon",
                layout = wibox.layout.align.horizontal,
                expand = "outside",
                nil,
                icon,
                nil,
            },
            nil,
        }
    }

    widget:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            if _G.dont_disturb == true then
                _G.dont_disturb = false
                icon.icon:set_markup_silently("")
                icon.icon.font = beautiful.font .. " Regular " .. size - 4
                widget.bg = beautiful.button_bg_off
                widget.fg = beautiful.fg_normal
            else
                _G.dont_disturb = true
                icon.icon:set_markup_silently("")
                icon.icon.font = beautiful.font .. " Regular " .. size
                widget.bg = beautiful.button_bg_on
                widget.fg = beautiful.bg_focus
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
