local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

require("helpers.widget")

local bluetooth_icon = require("ui.widgets.bluetooth")

local get_bg = function()
    return beautiful.bg_minimize .. beautiful.transparent
end

return function(size)
    local widget = wibox.widget {
        id = "icon_bg",
        widget = wibox.container.background,
        shape = gears.shape.circle,
        bg = get_bg(),
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
                bluetooth_icon(size),
                nil,
            },
            nil,
        }
    }

    return widget
end
