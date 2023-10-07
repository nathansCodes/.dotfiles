local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local balanced = wibox.widget {
    widget = wibox.container.rotate,
    direction = "west",
    {
        widget = wibox.widget.textbox,
        text = "󰂏",
        valign = "center",
        font = beautiful.font .. " Regular 28",
    }
}

local battery_saver = wibox.widget {
    widget = wibox.container.rotate,
    direction = "west",
    bg = beautiful.error,
    fg = beautiful.bg_focus,
    {
        widget = wibox.widget.textbox,
        text = "󰂏",
        valign = "center",
        font = beautiful.font .. " Regular 28",
    }
}

local perf = wibox.widget {
    widget = wibox.widget.textbox,
    text = "",
    valign = "center",
    halign = "center",
    bg = beautiful.second_accent,
    fg = beautiful.bg_focus,
    font = beautiful.font .. " Regular 36",
}

local icons = { balanced, battery_saver, perf }

local state = 1

local balanced_profile = "Ondemand"

local function apply_profile()
    if state == 1 then
        awful.spawn("cpupower-gui profile " .. balanced_profile)
    elseif state == 2 then
        awful.spawn("cpupower-gui profile Powersave")
    elseif state == 3 then
        awful.spawn("cpupower-gui profile Performance")
    end
end

return function()
    local icon_container = wibox.widget {
        widget = wibox.container.place,
        valign = "center",
        halign = "center",
        content_fill_horizontal = true,
        icons[1],
    }

    local widget = wibox.widget {
        id = "icon_bg",
        widget = wibox.container.background,
        shape = gears.shape.circle,
        bg = icons[1].bg or beautiful.button_bg_off,
        fg = icons[1].fg or beautiful.fg_normal,
        forced_width = dpi(28),
        forced_height = dpi(28),
        icon_container,
    }

    local function set_icon()
        local icon = icons[state]
        widget.bg = icon.bg or beautiful.button_bg_off
        widget.fg = icon.fg or beautiful.fg_normal
        icon_container:reset(icon_container)
        icon_container.children = { icon }
        apply_profile()
    end

    widget:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            state = state == 3 and 1 or state + 1
            set_icon()
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
