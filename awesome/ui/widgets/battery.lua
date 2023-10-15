local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

return function()
    local progressbar = wibox.widget {
        widget = wibox.widget.progressbar,
        color = beautiful.inactive .. beautiful.semi_transparent,
        background_color = beautiful.bg_transparent,
        margins = dpi(4),
        bar_shape = function(cr, w ,h)
            gears.shape.rounded_rect(cr, w, h, 2)
        end
    }

    local battery_icon = wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.font .. " Bold 16",
        halign = "center",
        valign = "center",
    }

    local widget = wibox.widget {
        widget = wibox.container.margin,
        left = dpi(-2),
        top = dpi(4),
        bottom = dpi(4),
        forced_width = dpi(42),
        {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(2),
            {
                widget = wibox.container.background,
                forced_width = dpi(37),
                bg = beautiful.bg_transparent,
                fg = beautiful.bg_normal,
                shape = function(cr, w, h)
                    gears.shape.rounded_rect(cr, w, h, 3)
                end,
                border_color = beautiful.text,
                border_width = dpi(2),
                {
                    layout = wibox.layout.stack,
                    progressbar,
                    {
                        widget = wibox.container.rotate,
                        direction = "west",
                        battery_icon,
                    }
                },
            },
            {
                widget = wibox.container.place,
                valign = "center",
                {
                    widget = wibox.container.background,
                    shape = gears.shape.rounded_bar,
                    forced_width = dpi(2),
                    forced_height = dpi(8),
                    bg = beautiful.text,
                }
            }
        }
    }

	local tooltip = awful.tooltip {
		markup = 'Loading...',
		objects = { widget },
		mode = 'outside',
		align = 'right',
		preferred_positions = {'left', 'right', 'top', 'bottom'},
		margin_leftright = dpi(8),
		margin_topbottom = dpi(8)
	}

    awful.widget.watch("acpitool", 1, function(_, stdout)
        local percent_str = stdout:match("%d?%d?%d?%.%d")
        local percent = tonumber(percent_str)
        progressbar.value = percent / 100

        local is_charging = stdout:match("Charging") ~= nil

        if percent <= 20 then
            progressbar.color = beautiful.error
        elseif percent <= 40 then
            progressbar.color = beautiful.warn2
        elseif percent <= 60 then
            progressbar.color = beautiful.warn
        elseif percent <= 75 then
            progressbar.color = beautiful.cyan
        elseif is_charging or percent <= 85 then
            progressbar.color = beautiful.green
        else
            progressbar.color = beautiful.inactive .. beautiful.semi_transparent
        end

        local tooltip_text = percent == 100 and "Battery <b>Full</b>\n"
                                            or  "Battery: <b>" .. percent_str .. "%</b>\n"

        local time_left = stdout:match("..:..:..")

        local time_left_hours = time_left ~= nil and tonumber(time_left:sub(1, 2))
        local time_left_min = time_left ~= nil and tonumber(time_left:sub(4, 5))

        if is_charging then
            battery_icon:set_text("󱐋")
            if time_left ~= nil then
                tooltip_text = tooltip_text .. "Time left until charged: <b>"
                                            .. tostring(time_left_hours) .. " h "
                                            .. tostring(time_left_min) .. " min</b>\n"
            end
        else
            battery_icon:set_text("")
            if time_left ~= nil then
                tooltip_text = tooltip_text .. "Time left on charge: <b>"
                                            .. tostring(time_left_hours) .. "h "
                                            .. tostring(time_left_min) .. " min</b>\n"
            end
        end

        if stdout:match("online") ~= nil then
            tooltip_text = tooltip_text .. "AC Adapter: <b>Online</b>"
        elseif percent <= 20 then
            tooltip_text = tooltip_text .. "Battery low, connect device to power source ASAP."
        else
            tooltip_text = tooltip_text .. "AC Adapter: <b>Offline</b>"
        end

        tooltip:set_markup(tooltip_text)
    end)

    return widget
end
