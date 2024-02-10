local wibox = require("wibox")
local gears = require("gears")
local gtable = gears.table
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local helpers = require("helpers")

local function make_bluetooth_card(device)
    local device_type = helpers.str.capitalize(device.icon:gsub("-", " "))

    if device_type == "" then
        device_type = "Miscellanious"
    end

    local widget = wibox.widget {
        widget = wibox.container.background,
        bg = beautiful.overlay,
        shape = helpers.ui.rrect(20),
        {
            widget = wibox.container.margin,
            margins = dpi(10),
            {
                layout = wibox.layout.fixed.horizontal,
                fill_space = true,
                spacing = dpi(10),
                {
                    layout = wibox.layout.fixed.vertical,
                    {
                        id = "device_name",
                        widget = wibox.widget.textbox,
                        font = beautiful.font .. "Bold 14",
                        text = device.name,
                    },
                    {
                        id = "device_type",
                        widget = wibox.widget.textbox,
                        font = beautiful.font .. "SemiBold 10",
                        markup = helpers.ui.colorize_text(device_type, beautiful.inactive),
                    }
                },
            }
        }
    }

    return widget
end

local layout = wibox.widget {
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(8),
}

local device_widget_table = { }

awesome.connect_signal("bluetooth::devices::blank", function()
    for _, widget in pairs(device_widget_table) do
        widget.satisfies = false
    end
end)

awesome.connect_signal("bluetooth::devices::add", function(device)
    -- return if device has no name (name == e.g. "FF-FF-FF-FF-FF-FF")
    if (device.name:match("[0-9A-F%-]+") or ""):len() == device.name:len() then return end

    local equals_device = function(k) return k == device.name end

    if gtable.find_first_key(device_widget_table, equals_device, false) ~= nil then

        local widget = device_widget_table[device.name]

        widget.satisfies = true

        --widget.children[1]:set_text("name: " .. device.name)
        --widget.children[2]:set_text("mac_address: " .. device.mac_address)
        --widget.children[3]:set_text("icon: " .. device.icon)
        --widget.children[4]:set_text("paired: " .. tostring(device.paired))
        --widget.children[5]:set_text("bonded: " .. tostring(device.bonded))
        --widget.children[6]:set_text("trusted: " .. tostring(device.trusted))
        --widget.children[7]:set_text("blocked: " .. tostring(device.blocked))
        --widget.children[8]:set_text("connected: " .. tostring(device.connected))

        return
    end

    local widget = make_bluetooth_card(device)

    widget.satisfies = true

    device_widget_table[device.name] = widget

    layout:add(widget)
end)

awesome.connect_signal("bluetooth::devices::update_end", function()
    for name, widget in pairs(device_widget_table) do
        if not widget.satisfies then
            layout:remove_widgets(widget)
            device_widget_table[name] = nil
        else
            widget.satisfies = false
        end
    end
end)

return layout
