local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local net_icon = require("ui.widgets.network")
require("helpers.widget")

local on

return function(size)
    local widget = wibox.widget {
        id = "icon_bg",
        widget = wibox.container.background,
        shape = gears.shape.circle,
        bg = beautiful.button_bg_off,
        {
            widget = wibox.container.place,
            valgin = "center",
            halgin = "center",
            content_fill_horizontal = true,
            net_icon(size),
        }
    }

    awful.widget.watch("/home/nathan/.dotfiles/scripts/check_network.sh", 1, function(_, stdout)
        on = stdout:match("disconnected")
            or stdout:match("connecting")
            or stdout:match("connected")

        if on ~= nil then
            widget.bg = beautiful.button_bg_on
            widget.fg = beautiful.bg_focus
        else
            widget.bg = beautiful.button_bg_off
            widget.fg = beautiful.fg_normal
        end
    end)

    local old_cursor, old_wibox

    widget:connect_signal( 'mouse::enter', function()
        local w = _G.mouse.current_wibox
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

    widget:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            if on ~= nil then
                awful.spawn.once("nmcli n off")
            else
                awful.spawn.once("nmcli n on")
            end
        end
    end)

    return widget
end
