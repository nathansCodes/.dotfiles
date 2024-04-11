----------------------------------------------------------------------------
--- Simple Network Widget
--
-- Depends: iproute2, iw
--
--
-- @author manilarome &lt;gerome.matilla07@gmail.com&gt;
-- @copyright 2020 manilarome
-- @widget network
----------------------------------------------------------------------------

local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local naughty = require('naughty')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi

local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. 'ui/icons/network/'
local button = require("ui.widget.button")
local helpers = require("helpers")
local settings = require("config.user_settings")

local instance = nil

local network_interfaces = {
    wlan = settings.device.network.wifi or "wlo1",
    lan = settings.device.network.lan or "eno1"
}

local network_mode = nil

local get_icon = function(strength)
    local icons = {
        "\u{ebe4}",
        "\u{ebd6}",
        "\u{ebe1}",
        "\u{f065}",
    }
    return icons[strength]
end

local return_button = function(size, show_notifications, cursor_focus, force_new)
    if instance ~= nil and not force_new then return wibox.widget.base.make_widget(instance) end

    cursor_focus = cursor_focus == nil and true or cursor_focus

    show_notifications = show_notifications == nil and true or show_notifications

	local startup = true
	local reconnect_startup = false

	local widget = wibox.widget {
        layout = wibox.container.place,
		{
            id = "stack",
            widget = wibox.layout.stack,
            top_only = false,
            {
                id = 'icon',
                text = '\u{f0b0}',
                widget = wibox.widget.textbox,
                font = beautiful.icon_font .. (size or 18),
                halign = "left",
                valign = "center",
            },
            {
                id = 'alert',
                widget = wibox.container.margin,
                visible = false,
                right = dpi(-(size / 4)),
                {
                    widget = wibox.widget.textbox,
                    markup = helpers.ui.colorize_text("\u{e645}", beautiful.warn),
                    valign = "bottom",
                    halign = "right",
                    font   = beautiful.icon_font .. "Bold " .. (size or 20) - 12,
                }
            },
		},
	}

	local widget_button = button.simple {
		widget = widget,
        change_cursor = cursor_focus,
        shape = gears.shape.rectangle,
        bg = gears.color.transparent,
        on_release = function(_, _, _, _, b)
            if b == 2 then
                awful.spawn(settings.program.default_apps.network_manager.command, false)
            end
        end,
	}

	local network_tooltip = awful.tooltip {
		text = 'Loading...',
		objects = {widget_button},
		mode = 'outside',
		align = 'right',
		preferred_positions = {'left', 'right', 'top', 'bottom'},
		margin_leftright = dpi(8),
		margin_topbottom = dpi(8)
	}

	local check_internet_health = [=[
	status_ping=0

	packets="$(ping -q -w2 -c2 example.com | grep -o "100% packet loss")"
	if [ -z "${packets}" ]; then
		status_ping=1
	fi

	if [ $status_ping -eq 0 ]; then
		echo 'Connected but no internet'
	fi
	]=]

	-- Awesome/System startup
	local update_startup = function()
		if startup then
			startup = false
		end
	end

	-- Consider reconnecting at startup
	local update_reconnect_startup = function(status)
		reconnect_startup = status
	end

	-- Update tooltip
	local update_tooltip = function(message)
		network_tooltip:set_markup(message)
	end

	local network_notification = function(message, title, app_name, icon)
        if not show_notifications then return end
		naughty.notification {
			message = message,
			title = title,
			app_name = app_name,
			icon = icon
		}
	end

	-- Wireless mode / Update
	local update_wireless = function()

		network_mode = 'wireless'

		-- Create wireless connection notification
		local notification_connected = function(essid)
			local message = 'You are now connected to ' .. essid
			local title = 'Connection Established'
			local app_name = 'System'
			local icon = widget_icon_dir .. 'connected_notification.svg'
			network_notification(message, title, app_name, icon)

            awesome.emit_signal("system::network_connected")
            widget_button:emit_signal("connected")
		end

		-- Get wifi essid and bitrate
		local update_wireless_data = function(strength, healthy)
			awful.spawn.easy_async_with_shell(
				[[
				iw dev ]] .. network_interfaces.wlan .. [[ link
				]],
				function(stdout)
					local essid = stdout:match('SSID: (.-)\n') or 'N/A'
					local bitrate = stdout:match('tx bitrate: (.+/s)') or 'N/A'
					local message = 'Connected to: <b>' .. (essid or 'Loading...*') ..
						'</b>\nWireless Interface: <b>' .. network_interfaces.wlan ..
						'</b>\nWiFi-Strength: <b>' .. tostring(wifi_strength) .. '%' ..
						'</b>\nBit rate: <b>' .. tostring(bitrate) .. '</b>'

					if healthy then
						update_tooltip(message)
					else
						update_tooltip('<b>Connected but no internet!</b>\n' .. message)
					end

					if reconnect_startup or startup then
                        if essid ~= 'N/A' then
                            notification_connected(essid)
                        end
						update_reconnect_startup(false)
					end
                    widget_button:emit_signal("connected")
				end
			)
		end

		-- Update wifi icon based on wifi strength and health
		local update_wireless_icon = function(strength)
			awful.spawn.easy_async_with_shell(
				check_internet_health,
				function(stdout)
					local icon = '\u{f0b0}'
					if not stdout:match('Connected but no internet') then
						if startup or reconnect_startup then
							awesome.emit_signal('system::network_connected')
						end
						icon = get_icon(strength)
                        widget.stack.alert.visible = false
						update_wireless_data(wifi_strength_rounded, true)
					else
						icon = get_icon(strength)
                        widget.stack.alert.visible = true
						update_wireless_data(wifi_strength_rounded, false)
					end
					widget.stack.icon:set_text(icon)
				end
			)
		end

		-- Get wifi strength
		local update_wireless_strength = function()
			awful.spawn.easy_async_with_shell(
				[[
				awk 'NR==3 {printf "%3.0f" ,($3/70)*100}' /proc/net/wireless
				]],
				function(stdout)
					if not tonumber(stdout) then
						return
					end
					wifi_strength = tonumber(stdout)
					wifi_strength_rounded = math.floor(wifi_strength / 25 + 0.5)
					update_wireless_icon(wifi_strength_rounded)
				end
			)
		end

		update_wireless_strength()
		update_startup()
	end

	local update_wired = function()

		network_mode = 'wired'

		local notification_connected = function()
			local message = 'Connected to internet with ' .. network_interfaces.lan
			local title = 'Connection Established'
			local app_name = 'System'
			local icon = widget_icon_dir .. 'wired.svg'
			network_notification(message, title, app_name, icon)

            awesome.emit_signal("system::network_connected")
            widget_button:emit_signal("connected")
		end

		awful.spawn.easy_async_with_shell(
			check_internet_health,
			function(stdout)

				local icon = '\u{eb2f}'

				if stdout:match('Connected but no internet') then
					icon = '󰲜'
					update_tooltip(
						'<b>Connected but no internet!</b>' ..
						'\nEthernet Interface: <b>' .. network_interfaces.lan .. '</b>'
					)
				else
					update_tooltip('Ethernet Interface: <b>' .. network_interfaces.lan .. '</b>')
					if startup or reconnect_startup then
						awesome.emit_signal('system::network_connected')
						notification_connected()
						update_startup(false)
					end
					update_reconnect_startup(false)
				end
				widget.stack.icon:set_text(icon)
			end
		)
	end

	local update_disconnected = function()

		local notification_wireless_disconnected = function(essid)
			local message = 'Wi-Fi network has been disconnected'
			local title = 'Connection Disconnected'
			local app_name = 'System'
			local icon = widget_icon_dir .. 'wifi-strength-off.svg'
			network_notification(message, title, app_name, icon)
		end

		local notification_wired_disconnected = function(essid)
			local message = 'Ethernet network has been disconnected'
			local title = 'Connection Disconnected'
			local app_name = 'System'
			local icon = widget_icon_dir .. 'wired-off.svg'
			network_notification(message, title, app_name, icon)
		end

		local icon = '\u{e1da}'

		if network_mode == 'wireless' then
			if not reconnect_startup then
				update_reconnect_startup(true)
				notification_wireless_disconnected()
			end
		elseif network_mode == 'wired' then
			if not reconnect_startup then
				update_reconnect_startup(true)
				notification_wired_disconnected()
			end
		end
		update_tooltip('Network is currently disconnected')
		widget.stack.icon:set_text(icon)
        widget.stack.alert.visible = false
        awesome.emit_signal("system::network_disconnected")
        widget_button:emit_signal("disconnected")
	end

	local check_network_mode = function()
		awful.spawn.easy_async_with_shell(
			[=[
			wireless="]=] .. tostring(network_interfaces.wlan) .. [=["
			wired="]=] .. tostring(network_interfaces.lan) .. [=["
			net="/sys/class/net/"

			wired_state="down"
			wireless_state="down"
			network_mode=""

			# Check network state based on interface's operstate value
			function check_network_state() {
				# Check what interface is up
				if [[ "${wireless_state}" == "up" ]];
				then
					network_mode='wireless'
				elif [[ "${wired_state}" == "up" ]];
				then
					network_mode='wired'
				else
					network_mode='No internet connection'
				fi
			}

			# Check if network directory exist
			function check_network_directory() {
				if [[ -n "${wireless}" && -d "${net}${wireless}" ]];
				then
					wireless_state="$(cat "${net}${wireless}/operstate")"
				fi
				if [[ -n "${wired}" && -d "${net}${wired}" ]]; then
					wired_state="$(cat "${net}${wired}/operstate")"
				fi
				check_network_state
			}

			# Start script
			function print_network_mode() {
				# Call to check network dir
				check_network_directory
				# Print network mode
				printf "${network_mode}"
			}

			print_network_mode

			]=],
			function(stdout)
				local mode = stdout:gsub('%\n', '')
				if stdout:match('No internet connection') then
					update_disconnected()
				elseif stdout:match('wireless') then
					update_wireless()
				elseif stdout:match('wired') then
					update_wired()
				end
			end
		)
	end

	local network_updater = gears.timer {
		timeout = 1,
		autostart = true,
		call_now = true,
		callback = function()
			check_network_mode()
		end
	}

    if instance == nil and not force_new then
        instance = widget_button
    end

	return widget_button
end

return return_button
