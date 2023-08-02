local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local clickable_container = require("ui.widgets.clickable-container")

local actions_template = wibox.widget {
    base_layout = wibox.widget {
        spacing        = dpi(0),
        layout         = wibox.layout.flex.horizontal
    },
    widget_template = {
        {
            {
                {
                    {
                        id     = 'text_role',
                        font = beautiful.font .. " Regular 10",
                        widget = wibox.widget.textbox
                    },
                    widget = wibox.container.place
                },
                widget = clickable_container
            },
            bg                 = beautiful.groups_bg,
            shape              = gears.shape.rounded_rect,
            forced_height      = dpi(30),
            widget             = wibox.container.background
        },
        margins = dpi(4),
        widget  = wibox.container.margin
    },
    style = { underline_normal = false, underline_selected = true },
    widget = naughty.list.actions
}

local notif_list = wibox.widget {
    base_layout = wibox.widget {
        layout = wibox.layout.flex.vertical,
        spacing = 4,
        spacing_widget = {
            orientation = "horizontal",
            widget = wibox.widget.separator,
        },
    },
    widget_template = {
        widget = wibox.container.background,
        bg = beautiful.bg_focus,
        shape = beautiful.notification_shape or function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 20)
        end,
        min_height = 50,
        {
            layout  = wibox.layout.fixed.vertical,
            spacing = dpi(4),
            {
                layout = wibox.layout.fixed.vertical,
                {
                    widget = wibox.container.background,
                    fg = beautiful.secondary_accent,
                    {
                        margins = beautiful.notification_margin,
                        widget  = wibox.container.margin,
                        naughty.widget.title
                    },
                },
                {
                    -- Margin between the fake background
                    -- Set to 0 to preserve the 'titlebar' effect
                    widget  = wibox.container.margin,
                    margins = dpi(0),
                    {
                        layout  = wibox.layout.fixed.vertical,
                        fill_space = true,
                        spacing = beautiful.notification_margin,
                        {
                            layout = wibox.layout.fixed.horizontal,
                            {
                                widget  = wibox.container.margin,
                                margins = beautiful.notification_margin,
                                {
                                    resize_strategy = 'center',
                                    widget = naughty.widget.icon,
                                },
                            },
                            {
                                widget  = wibox.container.margin,
                                margins = beautiful.notification_margin,
                                {
                                    layout = wibox.layout.align.vertical,
                                    expand = 'none',
                                    nil,
                                    {
                                        align = 'left',
                                        widget = naughty.widget.message,
                                    },
                                    actions_template,
                                },
                            },
                        },
                    },
                }
            },
        },
    },
    widget = naughty.list.notifications,
}

local clear_all = wibox.widget {
    widget = wibox.container.background,
    bg = beautiful.secondary_accent,
    fg = beautiful.bg_focus,
    shape = gears.shape.rounded_bar,
    {
        widget = wibox.container.margin,
        margins = 8,
        wibox.widget.textbox("clear all")
    }
}

clear_all:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        naughty.destroy_all_notifications(nil, 1)
    end
end)

return function()
    return wibox.widget {
        widget = wibox.container.background,
        bg = beautiful.bg_focus .. beautiful.semi_transparent,
        shape = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 20)
        end,
        {
            layout = wibox.layout.fixed.vertical,
            spacing_widget = wibox.widget.separator,
            spacing = 8,
            {
                widget = wibox.container.margin,
                left = 8,
                {
                    layout = wibox.layout.align.horizontal,
                    expand = "inside",
                    wibox.widget.textbox("Notifications"),
                    nil,
                    clear_all,
                }
            },
            notif_list,
        },
    }
end
