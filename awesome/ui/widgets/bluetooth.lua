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

local is_on
local checker


-- ===================================================================
-- Initialization
-- ===================================================================


local widget = wibox.widget {
   {
      id = "text",
      text = "󰂯",
      widget = wibox.widget.textbox,
      resize = true,
      font = beautiful.font .. " Medium 14",
   },
   layout = wibox.layout.align.horizontal
}

local widget_button = clickable_container(wibox.container.margin(widget, dpi(7), dpi(7), dpi(7), dpi(7)))
widget_button:buttons(
   gears.table.join(
      awful.button({}, 1, nil,
         function()
             awful.spawn("blueman-manager")
         end
      ),
      awful.button({}, 3, nil,
         function()
             if is_on then
                 awful.spawn("bluetoothctl power off")
             else
                 awful.spawn("bluetoothctl power on")
             end
             is_on = not is_on
         end
      )
   )
)

awful.tooltip {
    objects = {widget_button},
    mode = "outside",
    align = "right",
    timer_function = function()
        if is_on then
            return "Bluetooth is on"
        else
            return "Bluetooth is off"
        end
    end,
    preferred_positions = {"right", "left", "top", "bottom"}
}

local last_bluetooth_check = os.time()
watch("bluetoothctl", 5, function(_, stdout)
        -- Check if there bluetooth is on or off
        checker = stdout:match("PowerState: off")
        if (checker ~= nil) then
            widget.text.set_text("󰂯")
            is_on = true
        else
            widget.text.set_text("󰂲")
            is_on = false
        end
        collectgarbage("collect")
    end,
    widget
)

return widget_button
