local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local gfs = gears.filesystem
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local clickable_container = require("ui.widgets.clickable-container")

local function icon(icon)
    icon = icon or [[
        <svg style="clip-rule:evenodd;fill-rule:evenodd;stroke-linejoin:round;stroke-miterlimit:2" version="1.1" viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
            <path d="m17.387 45.391l3.91-5.484h17.453s4.968 0.082 4.968-7.006v-22.292c-0.313-4.851-4.714-5.223-4.714-5.223h-29.298s-5.424 0.318-5.502 5.605v21.91c9e-3 6.902 5.502 7.006 5.502 7.006h2.578l3.523 5.463c0.767 0.894 0.778 0.777 1.58 0.021z" style="fill-opacity:.67"/>
            <path d="m17.387 44.002l3.91-5.484h17.453s4.968 0.081 4.968-7.006v-22.293c-0.313-4.851-4.714-5.223-4.714-5.223h-29.298s-5.424 0.318-5.502 5.606v21.91c9e-3 6.902 5.502 7.006 5.502 7.006h2.578l3.523 5.462c0.767 0.895 0.778 0.778 1.58 0.022z" style="fill:url(#_Linear1)"/>
            <circle cx="32.84" cy="6.821" r="5.728" style="fill:url(#_Linear2)"/>
            <defs>
                <linearGradient id="_Linear1" x2="1" gradientTransform="matrix(.799284 -39.6049 39.6049 .799284 498.134 53.5618)" gradientUnits="userSpaceOnUse">
                    <stop style="stop-color:#908caa" offset="0"/>
                    <stop style="stop-color:#e0def4" offset="1"/>
                </linearGradient>
                <linearGradient id="_Linear2" x2="1" gradientTransform="matrix(7.01453e-16,-11.4556,11.4556,7.01453e-16,87.5702,12.5494)" gradientUnits="userSpaceOnUse">
                    <stop style="stop-color:#3e8fb0" offset="0"/>
                    <stop style="stop-color:#9ccfd8" offset="1"/>
                </linearGradient>
            </defs>
        </svg>
    ]]

    return wibox.widget {
        id = 'icon',
        widget = wibox.widget.imagebox,
        shape = gears.shape.rounded_rect,
        resize = true,
        forced_height = dpi(25),
        forced_width = dpi(25),
        image = icon,
    }
end

local function app_name(app_name)
    return wibox.widget {
        widget = wibox.widget.textbox,
        text = app_name,
        font = "Inter Regular 11",
    }
end

local function title(title)
    return wibox.widget {
        widget = wibox.widget.textbox,
        text = title,
        font = "Inter Bold 12",
    }
end

local function message(message)
    return wibox.widget {
        widget = wibox.widget.textbox,
        text = message,
        valign = "center",
        font = "Inter Regular 11"
    }
end

local function actions(n)
	return wibox.widget {
		widget = naughty.list.actions,
        style = { underline_normal = false, underline_selected = true },
		notification = n,
		base_layout = wibox.widget {
			spacing        = dpi(0),
			layout         = wibox.layout.flex.horizontal,
		},
		widget_template = {
			widget  = wibox.container.margin,
            margins = 4,
			{
				widget         = wibox.container.background,
				bg             = beautiful.groups_bg,
				shape          = gears.shape.rounded_rect,
				forced_height  = 35,
				{
                    widget = clickable_container,
                    {
                        widget = wibox.container.background,
                        bg = beautiful.bg_minimize .. beautiful.semi_transparent,
                        shape = gears.shape.rounded_rect,
                        {
                            widget = wibox.container.place,
                            {
                                id     = 'text_role',
                                font   = 'Inter Regular 10',
                                widget = wibox.widget.textbox
                            },
                        },
                    },
				},
			},
		},
	}
end

naughty.connect_signal('request::display', function(n)
    local notifbox = {
        notification = n,
        minimum_width = beautiful.notification_min_width,
        minimum_height = beautiful.notification_min_height,
        maximum_width = beautiful.notification_max_width,
        maximum_height = beautiful.notification_max_height,
        border_width = beautiful.notification_border_width or 2,
        border_color = n.urgency == "critical" and beautiful.error or beautiful.accent,
        type = 'notification',
        screen = awful.screen.preferred(),
        shape = beautiful.notification_shape or function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 20)
        end,
        widget_template = {
            widget  = wibox.container.background,
            bg = n.urgency == "critical" and beautiful.error or beautiful.accent,
            fg = beautiful.bg_focus,
            {
                layout = wibox.layout.fixed.vertical,
                {
                    widget  = wibox.container.margin,
                    top = beautiful.notification_margin,
                    bottom = beautiful.notification_margin,
                    left = 8,
                    right = 12,
                    {
                        layout = wibox.layout.align.horizontal,
                        icon(n.icon),
                        title(n.title),
                        app_name(n.app_name),
                    },
                },
                {
                    widget = wibox.container.background,
                    bg = beautiful.bg_focus,
                    fg = beautiful.fg_normal,
                    shape = function(cr, w, h)
                        gears.shape.rounded_rect(cr, w, h, 20)
                    end,
                    {
                        widget  = wibox.container.margin,
                        margins = 10,
                        {
                            layout = wibox.layout.fixed.vertical,
                            message(n.message),
                            actions(n),
                        },
                    },
                },
            }
        },
    }
    naughty.layout.box((_G.dont_disturb or _G.control_panel_vilible) and {} or notifbox)
end)
