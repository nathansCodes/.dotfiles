local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local rubato = require("rubato")

local net_button = require("ui.control_panel.net_button")
local bluetooth_button = require("ui.control_panel.bluetooth_button")
local dnd_icon = require("ui.control_panel.dnd")
local power_icon = require("ui.control_panel.power")
local right_ctrl = require("ui.control_panel.right_ctrl")

local notif_center = require("ui.control_panel.notification_center")
local wifi_menu = require("ui.control_panel.wifi_menu")

require("helpers.widget")

local control_panel = awful.popup {
    screen = screen[1],
    type = "popup_menu",

    width = dpi(500),
    maximum_width = dpi(500),
    minimum_height = dpi(800),
    maximum_height = dpi(800),

    visible = false,
    ontop = true,

    border_width = dpi(2),
    border_color = beautiful.border_focus .. beautiful.opaque,
    bg           = beautiful.bg_normal .. beautiful.fully_transparent,
    shape        = gears.shape.transform(function(cr, w, h)
        gears.shape.partially_rounded_rect(cr, w, h, false, false, true, true, dpi(20))
    end),

    placement = function(w)
        awful.placement.top_right(w, {
            margins = { top = dpi(30), bottom = dpi(5), left = dpi(0), right = dpi(10) },
        })
    end,

    widget = wibox.widget {
        widget = wibox.container.margin,
        top = dpi(20),
        bottom = dpi(14),
        left = dpi(14),
        right = dpi(14),
        {
            layout = wibox.layout.fixed.vertical,
            fill_space = true,
            spacing = dpi(16),
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(16),
                forced_height = dpi(200),
                {
                    widget = wibox.container.background,
                    bg = beautiful.bg_focus .. beautiful.transparent,
                    forced_width = dpi(200),
                    forced_height = dpi(200),
                    shape = function(cr, w, h)
                        gears.shape.rounded_rect(cr, w, h, dpi(20))
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
                            net_button(30),
                            bluetooth_button(34),
                            dnd_icon(),
                            power_icon(),
                        }
                    }
                },
                right_ctrl()
            },
            {
                id = "lower",
                layout = wibox.layout.flex.vertical,
                notif_center.notif_center
            }
        },
    },
}

function control_panel.toggle()
    control_panel.visible = not control_panel.visible
    _G.control_panel_vilible = control_panel.visible
end

awesome.connect_signal("control_panel::toggle_wifi_menu", function()
    local lower_widget = control_panel.widget:get_children_by_id("lower")[1]
    if lower_widget.children[1] == notif_center.notif_center then
        lower_widget:reset(lower_widget)
        lower_widget:insert(1, wifi_menu)
    else
        lower_widget:reset(lower_widget)
        lower_widget:insert(1, notif_center.notif_center)
    end
end)

return control_panel
