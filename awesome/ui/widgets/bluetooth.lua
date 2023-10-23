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
local clickable_container = require("ui.widgets.clickable-container")
local gears = require("gears")
local gfs = gears.filesystem
local dpi = require("beautiful").xresources.apply_dpi

local apps = require("config.apps")

local checker_on
local checker_connected


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

    watch(gfs.get_configuration_dir() .. "/../scripts/check_bluetooth.sh", 1, function(_, stdout)
        checker_connected = stdout:match("connected")
        checker_on = stdout:match("on")
        local icon
        if (checker_connected ~= nil) then
            icon = "\u{e1a8}"
        elseif (checker_on ~= nil) then
            icon = "\u{e1a7}"
        else
            icon = "\u{e1a9}"
        end
        widget:set_text(icon)
        collectgarbage("collect")
    end, widget)

	local widget_button = wibox.widget {
        widget = clickable_container,
        change_cursor = cursor_focus,
        widget,
	}

	widget_button:buttons(
		gears.table.join(
			awful.button({}, 2, nil,
				function()
					awful.spawn(apps.default.bluetooth_manager, false)
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
