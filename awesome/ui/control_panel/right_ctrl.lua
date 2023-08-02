local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local volume_widget = require("ui.widgets.volume")
local slider = require("ui.control_panel.slider")
local player = require("ui.control_panel.player")

require("helpers.widget")


local brightness_slider = slider({}, function(value)
    awful.spawn("light -S " .. value .. "%", false)
end)

local brightness_icon = wibox.widget {
    {
        text = "󰃟",
        font = beautiful.font .. " Regular 28",
        widget = wibox.widget.textbox,
    },
    valign = 'center',
    forced_width = 28,
    layout = wibox.container.place,
}

local volume_icon = volume_widget {
    device = "pipewire",
    size = 28,
}

local volume_slider = slider({}, function(value)
    awful.spawn("amixer -D pulse sset Master " .. value .. "%", false)
end)

return function()
    return {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(16),
        fill_space = true,
        format_item {
            layout = wibox.layout.fixed.vertical,
            spacing = dpi(0),
            forced_height = dpi(100),
            format_item {
                layout = wibox.layout.fixed.horizontal,
                bg = beautiful.bg_transparent,
                forced_height = dpi(40),
                spacing = dpi(4),
                left = dpi(6),
                right = dpi(6),
                volume_icon,
                volume_slider,
            },
            format_item {
                layout = wibox.layout.fixed.horizontal,
                bg = beautiful.bg_transparent,
                forced_height = dpi(40),
                spacing = dpi(4),
                left = dpi(6),
                right = dpi(6),
                brightness_icon,
                brightness_slider,
            },
        },
        player(),
    }
end
