--      ██████╗ ██╗     ██╗   ██╗███████╗████████╗ ██████╗  ██████╗ ████████╗██╗  ██╗
--      ██╔══██╗██║     ██║   ██║██╔════╝╚══██╔══╝██╔═══██╗██╔═══██╗╚══██╔══╝██║  ██║
--      ██████╔╝██║     ██║   ██║█████╗     ██║   ██║   ██║██║   ██║   ██║   ███████║
--      ██╔══██╗██║     ██║   ██║██╔══╝     ██║   ██║   ██║██║   ██║   ██║   ██╔══██║
--      ██████╔╝███████╗╚██████╔╝███████╗   ██║   ╚██████╔╝╚██████╔╝   ██║   ██║  ██║
--      ╚═════╝ ╚══════╝ ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝  ╚═════╝    ╚═╝   ╚═╝  ╚═╝

-- ===================================================================
-- Initialization
-- ===================================================================


local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local gfs = gears.filesystem
local dpi = require("beautiful").xresources.apply_dpi

local apps = require("config.apps")
local button = require("ui.widget.button")

local checker_on = false
local checker_connected = false


-- ===================================================================
-- Initialization
-- ===================================================================

return function(size, cursor_focus)
    cursor_focus = cursor_focus == nil and true or cursor_focus

    local widget = wibox.widget {
        text = '\u{e1a7}',
        widget = wibox.widget.textbox,
        font = beautiful.icon_font .. (size or 18),
        halign = "center",
    }

	local widget_button = button.simple {
        change_cursor = cursor_focus,
        bg = gears.color.transparent,
        on_release = function(_, _, _, _, b)
            if b == 2 then
                awful.spawn(apps.bluetooth_manager, false)
            end
        end,
        widget = widget,
	}

    watch(gfs.get_configuration_dir() .. "scripts/check_bluetooth.sh", 1, function(_, stdout)
        local was_connected = checker_connected
        local was_on = checker_on
        checker_connected = stdout:match("connected") ~= nil
        checker_on = stdout:match("on") ~= nil

        local icon

        if checker_connected then
            icon = "\u{e1a8}"
            local connected_device = string.sub(stdout, 11)

            if not was_connected then
                widget_button:emit_signal("connected", connected_device)
            end
            if not was_on then
                widget_button:emit_signal("enabled")
            end
        elseif checker_on then
            icon = "\u{e1a7}"

            if was_connected then
                widget_button:emit_signal("disconnected")
            end
            if not was_on then
                widget_button:emit_signal("enabled")
            end
        else
            icon = "\u{e1a9}"

            if was_connected then
                widget_button:emit_signal("disconnected")
            end
            if was_on or was_connected then
                widget_button:emit_signal("disabled")
            end
        end
        widget:set_text(icon)
        collectgarbage("collect")
    end, widget)

	widget_button:buttons(
		gears.table.join(
			awful.button({}, 2, nil,
				function()
				end
			)
		)
	)


    awful.tooltip {
        objects = {widget_button},
        mode = "outside",
        align = "right",
        timer_function = function()
            if checker_connected ~= nil then
                return "Bluetooth connected"
            elseif checker_on ~= nil then
                return "Bluetooth is on"
            else
                return "Bluetooth is off"
            end
        end,
        preferred_positions = {"right", "left", "top", "bottom"}
    }

    function widget_button.get_state()
        if checker_connected ~= nil then
            return "connected"
        elseif checker_on ~= nil then
            return "on"
        end
        return "off"
    end

    return widget_button
end
