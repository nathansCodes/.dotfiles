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
    font = beautiful.font .. " Regular 11",
    align = "center",
}

local brightness_slider = slider {
    handle_color = beautiful.third_accent,
    bar_active_color = beautiful.forth_accent,
    minimum = 10,
    on_changed = function(value)
        awful.spawn("light -S " .. value .. "%", false)
        brightness_percent:set_text(value .. "%")
    end
}

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
    if not brightness_slider.pressed then
        awful.spawn.easy_async_with_shell("light -G | awk -F '.' '{print $1}'", function(stdout)
            local brightness_level = stdout:match(".*")
            brightness_level = string.format("% 3d", brightness_level)
            brightness_slider:set_value(tonumber(brightness_level))
        end)
    end
end

awful.widget.watch("light -G | awk -F '.' '{print $1}'", 1, function(_, stdout)
    if not brightness_slider.pressed then
        local brightness_level = stdout:match(".*")
        brightness_level = string.format("% 3d", brightness_level)
        brightness_slider:set_value(tonumber(brightness_level))
    end
end)

awesome.connect_signal("system::update_brightness", update_brightness)


local volume_icon = volume_widget {
    device = "pipewire",
    size = 19,
    forced_width = dpi(28),
}

local volume_percent = wibox.widget {
    widget = wibox.widget.textbox,
    font = beautiful.font .. " Regular 11",
    align = "center",
}

local volume_slider = slider {
    handle_color = beautiful.third_accent,
    bar_active_color = beautiful.forth_accent,
    on_changed = function(value)
        awful.spawn("amixer -D pipewire sset Master " .. value .. "%", false)
        volume_percent:set_text(value .. "%")
    end
}

local function update_volume()
    awful.spawn.with_shell("amixer -D pipewire sget Master", function(stdout)
        if not volume_slider.pressed then
            local volume_level = string.match(stdout, "(%d?%d?%d)%%") -- (\d?\d?\d)\%)
            volume_level = string.format("% 3d", volume_level)
            volume_slider:set_value(tonumber(volume_level))
        end
    end)
end

awful.widget.watch("amixer -D pipewire sget Master", 1, function(_, stdout)
    if not volume_slider.pressed then
        local volume_level = string.match(stdout, "(%d?%d?%d)%%") -- (\d?\d?\d)\%)
        volume_level = string.format("% 3d", volume_level)
        volume_slider:set_value(tonumber(volume_level))
    end
end)

awesome.connect_signal("system::update_volume", update_volume)

return function()
    return {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(16),
        fill_space = true,
        format_item {
            layout = wibox.layout.fixed.vertical,
            bg = beautiful.bg_focus .. beautiful.transparent,
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
