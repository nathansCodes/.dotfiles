local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local rubato = require("rubato")

local net_icon = require("ui.control_panel.net_icon")
local bluetooth_icon = require("ui.control_panel.bluetooth_icon")
local volume_widget = require("ui.widgets.volume")
local slider = require("ui.control_panel.slider")

require("helpers.widget")


local volume_slider = slider({}, function(value)
    awful.spawn.once("amixer -D pulse sset Master " .. value .. "%", false)
end)

local volume_icon = volume_widget {
    device = "pipewire",
    size = 30,
}

local control_panel = awful.popup {
    screen = screen[1],
    type = "popup_menu",

    width = dpi(400),
    maximum_width = dpi(400),
    minimum_width = dpi(400),
    maximum_height = dpi(250),
    minimum_height = dpi(250),

    visible = false,
    ontop = true,

    border_width = 2,
    border_color = beautiful.border_focus .. beautiful.opaque,
    bg           = beautiful.bg_normal .. beautiful.transparent,
    shape        = function(cr, w, h)
        gears.shape.partially_rounded_rect(cr, w, h, false, false, true, true, 20)
    end,

    placement = function(w)
        awful.placement.top_right(w, {
            margins = { top = dpi(30), bottom = dpi(5), left = dpi(0), right = dpi(9) },
        })
    end,

    widget = {
        widget = wibox.container.margin,
        top = dpi(24),
        bottom = dpi(14),
        left = dpi(14),
        right = dpi(14),
        {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(16),
            forced_height = dpi(200),
            {
                widget = wibox.container.background,
                bg = beautiful.bg_focus .. beautiful.semi_transparent,
                forced_width = dpi(200),
                forced_height = dpi(200),
                shape = function(cr, w, h)
                    gears.shape.rounded_rect(cr, w, h, 20)
                end,
                {
                    widget = wibox.container.margin,
                    margins = dpi(20),
                    {
                        layout = wibox.layout.grid,
                        margins = dpi(10),
                        expand = "none",
                        homogeneous = false,
                        forced_num_cols = 2,
                        forced_num_rows = 2,
                        spacing = dpi(16),
                        net_icon(34),
                        bluetooth_icon(34),
                        bluetooth_icon(34),
                        net_icon(34),
                    }
                }
            },
            {
                layout = wibox.layout.fixed.vertical,
                format_item {
                    spacing = dpi(10),
                    layout = wibox.layout.align.horizontal,
                    {
                        widget = wibox.container.background,
                        bg = beautiful.transparent,
                        shape = function (cr, w, h)
                            gears.shape.rounded_rect(cr, w, h, 15)
                        end,
                        {
                            widget = wibox.container.margin,
                            margins = dpi(5),
                            volume_icon,
                        },
                    },
                    volume_slider,
                },
            }
        },
    },
}

function control_panel.toggle()
    control_panel.visible = not control_panel.visible
end

return control_panel
