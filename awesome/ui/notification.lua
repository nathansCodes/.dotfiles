local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local gfs = gears.filesystem
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local clickable_container = require("ui.widgets.clickable-container")

naughty.connect_signal( 'request::display', function(n)
    -- Actions Blueprint
    local actions_template = wibox.widget {
        notification = n,
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

    -- Notifbox Blueprint
    local notifbox = {
        notification = n,
        minimum_width = beautiful.notification_min_width,
        minimum_height = beautiful.notification_min_height,
        maximum_width = beautiful.notification_max_width,
        maximum_height = beautiful.notification_max_height,
        border_width = beautiful.notification_border_width or 2,
        border_color = beautiful.border_focus,
        type = 'notification',
        screen = awful.screen.preferred(),
        shape = beautiful.notification_shape or function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 20)
        end,
        widget_template = {
            widget  = wibox.container.background,
            bg = beautiful.accent,
            fg = beautiful.bg_focus,
            {
                layout = wibox.layout.fixed.vertical,
                {
                    widget  = wibox.container.margin,
                    top = beautiful.notification_margin,
                    bottom = beautiful.notification_margin,
                    left = 12,
                    right = 12,
                    naughty.widget.title { font = beautiful.font .. " Bold 12" },
                },
                {
                    widget = wibox.container.background,
                    bg = beautiful.bg_focus,
                    fg = beautiful.fg_normal,
                    shape = function(cr, w, h)
                        gears.shape.rounded_rect(cr, w, h, 20)
                    end,
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
                    },
                },
            }
        },
    }
    naughty.layout.box(_G.dont_disturb and {} or notifbox)
end)
