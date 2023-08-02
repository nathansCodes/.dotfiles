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
local dpi = require("beautiful").xresources.apply_dpi

local apps = require("config.apps")

local checker_on
local checker_connected


-- ===================================================================
-- Initialization
-- ===================================================================

return function(size)
    local widget = wibox.widget {
		{
			id = 'icon',
			text = '󰂯',
			widget = wibox.widget.textbox,
            font = beautiful.font .. " Regular " .. (size or 18) - 6,
		},
        resize = true,
		layout = wibox.layout.align.horizontal,
        expand = "none",
    }

    watch("/home/nathan/.dotfiles/scripts/check_bluetooth.sh", 1, function(_, stdout)
        checker_connected = stdout:match("connected")
        checker_on = stdout:match("on")
        local icon
        if (checker_connected ~= nil) then
            icon = "󰂱"
            widget.icon.font = beautiful.font .. " Regular " .. (size or 18)
        elseif (checker_on ~= nil) then
            icon = "󰂯"
            widget.icon.font = beautiful.font .. " Regular " .. (size or 18) - 6
        else
            icon = "󰂲"
            widget.icon.font = beautiful.font .. " Regular " .. (size or 18) - 2
        end
        widget.icon:set_text(icon)
        collectgarbage("collect")
    end, widget)

	local widget_button = wibox.widget {
		{
			widget,
			top = dpi(0),
			bottom = dpi(0),
			widget = wibox.container.margin
		},
		widget = clickable_container
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


    awful.tooltip( {
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
    } )

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
