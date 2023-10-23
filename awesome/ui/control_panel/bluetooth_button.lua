local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local button = require("ui.widgets.button")

local bluetooth_icon = require("ui.widgets.bluetooth")

local connected
local on

return function(size)
    local icon = bluetooth_icon(size, false)

    local widget = button {
        id = "icon_bg",
        widget = wibox.container.background,
        shape = gears.shape.circle,
        top = true,
        right = true,
        bg = beautiful.button_bg_off,
        callback = function(_, _, _, b)
            if b == 1 then
                if on == nil then
                    awful.spawn("bluetoothctl power on")
                else
                    awful.spawn("bluetoothctl power off")
                end
            end
        end,
        icon,
    }

    awful.widget.watch("/home/nathan/.dotfiles/scripts/check_bluetooth.sh", 1, function(_, stdout)
        connected = stdout:match("connected")
        on = stdout:match("on")

        if widget.pressed then return end

        if connected ~= nil then
            widget:set_bg(beautiful.button_bg_on)
            widget:set_fg(beautiful.bg_focus)
        elseif on ~= nil then
            widget:set_bg(beautiful.button_bg_on)
            widget:set_fg(beautiful.bg_focus)
        else
            widget:set_bg(beautiful.button_bg_off)
            widget:set_fg(beautiful.fg_normal)
        end
    end)

    return widget
end
