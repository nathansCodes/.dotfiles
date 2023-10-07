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

function icon(icon)
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
                widget = clickable_container,
                {
                    widget = wibox.container.background,
                    bg = beautiful.highlight_med .. beautiful.semi_transparent,
                    forced_height  = 35,
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
	}
end

local return_date_time = function(format)
	return os.date(format)
end

local parse_to_seconds = function(time)
	local hourInSec = tonumber(string.sub(time, 1, 2)) * 3600
	local minInSec = tonumber(string.sub(time, 4, 5)) * 60
	local getSec = tonumber(string.sub(time, 7, 8))
	return (hourInSec + minInSec + getSec)
end

naughty.connect_signal('request::display', function(n)
	local time_of_pop = return_date_time('%H:%M:%S')
	local exact_time = return_date_time('%I:%M %p')
	local exact_date_time = return_date_time('%b %d, %I:%M %p')

    local notifbox_timepop =  wibox.widget {
		id = 'time_pop',
		markup = nil,
		font = 'Inter Regular 10',
		align = 'right',
		valign = 'center',
		visible = true,
		widget = wibox.widget.textbox
	}

	local time_of_popup = gears.timer {
		timeout   = 60,
		call_now  = true,
		autostart = true,
		callback  = function()
			local time_difference = nil

			time_difference = parse_to_seconds(return_date_time('%H:%M:%S')) - parse_to_seconds(time_of_pop)
			time_difference = tonumber(time_difference)

			if time_difference < 60 then
				notifbox_timepop:set_markup('now')
			elseif time_difference >= 60 and time_difference < 3600 then
				local time_in_minutes = math.floor(time_difference / 60)
				notifbox_timepop:set_markup(time_in_minutes .. 'm ago')
			elseif time_difference >= 3600 and time_difference < 86400 then
				notifbox_timepop:set_markup(exact_time)
			elseif time_difference >= 86400 then
				notifbox_timepop:set_markup(exact_date_time)
				return false
            end

			collectgarbage('collect')
		end
	}

    local icon_backup = [[
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

    local notifbox = {
        notification = n,
        minimum_width = beautiful.notification_min_width or dpi(450),
        minimum_height = beautiful.notification_min_height or dpi(150),
        maximum_width = beautiful.notification_max_width or dpi(650),
        maximum_height = beautiful.notification_max_height or dpi(550),
        border_width = beautiful.notification_border_width or dpi(1),
        border_color = n.urgency == "critical" and beautiful.error or beautiful.accent,
        type = 'notification',
        screen = awful.screen.preferred(),
        shape = beautiful.notification_shape or function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 20)
        end,
        bg = n.urgency == "critical" and beautiful.error .. beautiful.transparent
        or beautiful.bg_normal .. beautiful.transparent,
        widget_template = {
            layout = wibox.layout.fixed.vertical,
            spacing = 0,
            {
                widget = wibox.container.margin,
                top = 4,
                bottom = 0,
                left = 4,
                right = 8,
                {
                    layout = wibox.layout.fixed.horizontal,
                    fill_space = true,
                    icon(n.icon or icon_backup),
                    title(n.title),
                    {
                        widget = wibox.container.margin,
                        left = 8,
                        app_name(n.app_name),
                    },
                    notifbox_timepop,
                }
            },
            {
                widget = wibox.container.margin,
                left = 8,
                right = 8,
                top = 0,
                bottom = 4,
                {
                    widget = wibox.widget.textbox,
                    text = n.message,
                    valign = "center",
                    font = "Inter Regular 11"
                },
            },
            actions(n)
        },
    }
    if not (_G.dont_disturb or _G.control_panel_vilible) then
        naughty.layout.box(notifbox)
    end
end)
