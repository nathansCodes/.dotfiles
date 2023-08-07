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

local brightness_percent = wibox.widget {
    widget = wibox.widget.textbox,
    text = "0%",
    align = "center",
}

local brightness_slider = slider({}, function(value)
    awful.spawn("light -S " .. value .. "%", false)
    brightness_percent:set_text(value .. "%")
end)

local brightness_icon = wibox.widget {
    {
        text = "󰃟",
        font = beautiful.font .. " Regular 16",
        widget = wibox.widget.textbox,
        forced_width = dpi(28),
    },
    valign = 'center',
    halign = 'center',
    layout = wibox.container.place,
}

local function update_brightness()
    awful.widget.watch("light -G | awk -F '.' '{print $1}'", 1, function(_, stdout)
        local brightness_level = stdout:match(".*")
        brightness_level = string.format("% 3d", brightness_level)
        brightness_slider:set_value(tonumber(brightness_level))
    end)
end

update_brightness()

awesome.connect_signal("system::update_brightness", update_brightness)

local volume_icon = volume_widget {
    device = "pipewire",
    size = 19,
    forced_width = dpi(28),
}

local volume_percent = wibox.widget {
    widget = wibox.widget.textbox,
    text = "0%",
    align = "center",
}

local volume_slider = slider({}, function(value)
    awful.spawn("amixer -D pipewire sset Master " .. value .. "%", false)
    volume_percent:set_text(value .. "%")
end)

local function update_volume()
    awful.widget.watch("amixer -D pipewire sget Master", 1, function(_, stdout)
        local volume_level = string.match(stdout, "(%d?%d?%d)%%") -- (\d?\d?\d)\%)
        volume_level = string.format("% 3d", volume_level)
        volume_slider:set_value(tonumber(volume_level))
    end)
end

update_volume()

awesome.connect_signal("system::update_volume", update_volume)

return function()
    return {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(16),
        fill_space = true,
        format_item {
            layout = wibox.layout.fixed.vertical,
            bg = beautiful.bg_focus .. beautiful.transparent,
            border_width = 1,
            border_color = beautiful.bg_minimize .. beautiful.transparent,
            spacing = dpi(0),
            forced_height = dpi(100),
            format_item {
                layout = wibox.layout.align.horizontal,
                bg = beautiful.bg_transparent,
                forced_height = dpi(40),
                spacing = dpi(4),
                left = dpi(2),
                right = dpi(2),
                volume_icon,
                volume_slider,
                {
                    widget = wibox.container.margin,
                    left = 4,
                    forced_width = 40,
                    volume_percent,
                },
            },
            format_item {
                layout = wibox.layout.align.horizontal,
                bg = beautiful.bg_transparent,
                forced_height = dpi(40),
                spacing = dpi(4),
                left = dpi(2),
                right = dpi(2),
                brightness_icon,
                brightness_slider,
                {
                    widget = wibox.container.margin,
                    left = 4,
                    forced_width = 40,
                    brightness_percent,
                },
            },
        },
        player(),
    }
end
