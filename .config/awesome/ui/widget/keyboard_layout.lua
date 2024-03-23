local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local user_settings = require("config.user_settings")

local current_layout_index = 1

local instance

return function()
    if instance then return instance end

    local layouts = user_settings.layouts
    local layout = wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.font .. "SemiBold 12",
        text = layouts[1]
    }

    local function next_layout()
        current_layout_index = current_layout_index + 1

        if layouts[current_layout_index] == nil then
            current_layout_index = 1
        end
        layout:set_text(layouts[current_layout_index])
        awful.spawn("setxkbmap " .. layouts[current_layout_index])
    end

    layout:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then next_layout() end
    end)

    awesome.connect_signal("keyboard::cycle_layouts", function() next_layout() end)

    instance = wibox.widget {
        widget = wibox.container.margin,
        right = dpi(5),
        {
            widget = wibox.container.place,
            valign = "center",
            layout,
        }
    }

    awful.spawn("setxkbmap " .. layouts[current_layout_index])

    return instance
end
