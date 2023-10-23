local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local button = require("ui.widgets.button")

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
    text = "\u{e4cb}",
    valign = "center",
    halign = "center",
    bg = beautiful.second_accent,
    fg = beautiful.bg_focus,
    font = beautiful.icon_font .. "28",
}

local icons = { balanced, battery_saver, perf }

local state = 1

local function apply_profile()
    if state == 1 then
        awful.spawn("cpupower-gui profile Balanced")
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

    local widget = button {
        id = "icon_bg",
        widget = wibox.container.background,
        shape = gears.shape.circle,
        bg = icons[1].bg or beautiful.button_bg_off,
        fg = icons[1].fg or beautiful.fg_normal,
        right = true,
        bottom = true,
        forced_width = dpi(28),
        forced_height = dpi(28),
        callback = function(self, _, _, b)
            if b ~= 1 then return end
            state = state == 3 and 1 or state + 1

            local icon = icons[state]
            self.bg = icon.bg or beautiful.button_bg_off
            self.fg = icon.fg or beautiful.fg_normal
            icon_container:reset(icon_container)
            icon_container.children = { icon }

            apply_profile()
        end,
        icon_container,
    }

    return widget
end
