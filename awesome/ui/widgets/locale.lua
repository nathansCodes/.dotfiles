local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local current_layout_index = 1

return function(layouts)
    local widget =  awful.widget.keyboardlayout()

    widget:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            current_layout_index = current_layout_index + 1

            if layouts[current_layout_index] == nil then
                current_layout_index = 1
            end
            awful.spawn("setxkbmap " .. layouts[current_layout_index])
        end
    end)

    return widget
end
