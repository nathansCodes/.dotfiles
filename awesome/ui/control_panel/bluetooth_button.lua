local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local bluetooth_icon = require("ui.widgets.bluetooth")

local connected
local on

return function(size)
    local icon = bluetooth_icon(size, false)

    local widget = wibox.widget {
        id = "icon_bg",
        widget = wibox.container.background,
        shape = gears.shape.circle,
        bg = beautiful.button_bg_off,
        {
            widget = wibox.container.place,
            valgin = "center",
            halgin = "left",
            content_fill_horizontal = true,
            icon,
        }
    }

    awful.widget.watch("/home/nathan/.dotfiles/scripts/check_bluetooth.sh", 1, function(_, stdout)
        connected = stdout:match("connected")
        on = stdout:match("on")
        if connected ~= nil then
            widget.bg = beautiful.button_bg_on
            widget.fg = beautiful.bg_focus
        elseif on ~= nil then
            widget.bg = beautiful.button_bg_on
            widget.fg = beautiful.bg_focus
        else
            widget.bg = beautiful.button_bg_off
            widget.fg = beautiful.fg_normal
        end
    end)

    widget:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            if on == nil then
                awful.spawn("bluetoothctl power on")
            else
                awful.spawn("bluetoothctl power off")
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
