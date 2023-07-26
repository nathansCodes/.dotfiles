local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local net_icon = require("ui.widgets.network")
require("helpers.widget")

local is_on

local bg_inactive = beautiful.bg_minimize .. beautiful.transparent
local bg_loading = beautiful.bg_minimize .. beautiful.semi_transparent
local bg_active = beautiful.pine .. beautiful.transparent

local bg = bg_inactive

return function(size)
    local widget = wibox.widget {
        id = "icon_bg",
        widget = wibox.container.background,
        shape = gears.shape.circle,
        bg = bg,
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
                net_icon(size),
                nil,
            },
            nil,
        }
    }

    widget:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            if is_on then
                is_on = false
                awful.spawn.once("nmcli n off")
                widget:get_children_by_id("icon_bg").bg = bg_inactive
            else
                is_on = true
                awful.spawn.once("nmcli n on")
                widget:get_children_by_id("icon_bg").bg = bg_active
            end
        end
    end)

    return widget
end
