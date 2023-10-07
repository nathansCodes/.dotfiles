local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local scroller = require("ui.widgets.scroller")

local connected_network = wibox.widget {
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(6),
    margin_top = 0,
}

local layout = scroller {
    orientation = "vertical",
    spacing = dpi(6),
}

local back_button = wibox.widget {
    widget = wibox.widget.textbox,
    font = "JetBrainsNerdFontMono Regular 24",
    valign = "center",
    text = ' ',
    buttons = {
        awful.button({}, 1, function()
            awesome.emit_signal("control_panel::toggle_wifi_menu")
        end),
    },
}

local old_cursor, old_wibox

back_button:connect_signal( 'mouse::enter', function()
    local w = _G.mouse.current_wibox
    if w then
        old_cursor, old_wibox = w.cursor, w
        w.cursor = 'hand1'
    end
end)

back_button:connect_signal( 'mouse::leave', function()
    if old_wibox then
        old_wibox.cursor = old_cursor
        old_wibox = nil
    end
end)

local title = wibox.widget {
    widget = wibox.widget.textbox,
    font = "Inter Bold 16",
    valign = "center",
    text = "Wifi Networks",
}


local function update()
    local builder = require("ui.control_panel.wifi_menu.wifi_card_builder")
    local i = 1

    local children = layout:get_children()
    awful.spawn.with_line_callback("nmcli --get-values ssid,security,in-use,signal d wifi", {
        stdout = function(line)
            -- remove networks with empty ssids
            local colon_pos, _ = line:find(":")
            if colon_pos == 1 then return end

            local ssid = line:match("^[^:]+")
            local password_needed = line:match("(:).+(:.:)") ~= nil
            local strength = line:match("[^:]+$")
            local is_connected = line:match(": :") == nil

            if is_connected then
                if connected_network.children[1] == nil then
                    connected_network:reset(connected_network)
                    connected_network:insert(1, builder.build_wifi_card(ssid, strength, is_connected, password_needed))
                else
                    connected_network.children[1]:update(ssid, strength, is_connected, password_needed)
                end
            else
                if children[i] ~= nil then
                    children[i]:update(ssid, strength, is_connected, password_needed)
                else
                    layout:insert(i, builder.build_wifi_card(ssid, strength, is_connected, password_needed))
                end
                i = i + 1
            end
        end
    })

    --TODO: reset the connected_network widget if it's not connected
end

local reload_button = wibox.widget {
    widget = wibox.widget.textbox,
    font = "JetBrainsNerdFontMono Regular 24",
    valign = "center",
    text = '󰑓 ',
    buttons = { awful.button({}, 1, update), },
}

local old_cursor, old_wibox

reload_button:connect_signal( 'mouse::enter', function()
    local w = _G.mouse.current_wibox
    if w then
        old_cursor, old_wibox = w.cursor, w
        w.cursor = 'hand1'
    end
end)

reload_button:connect_signal( 'mouse::leave', function()
    if old_wibox then
        old_wibox.cursor = old_cursor
        old_wibox = nil
    end
end)

local updater = gears.timer {
    timeout = 5,
    call_now = true,
    autostart = true,
    callback = update,
}

local wifi_menu = wibox.widget {
    widget = wibox.container.background,
    bg = beautiful.bg_focus .. beautiful.transparent,
    shape = beautiful.base_shape,
    {
        layout = wibox.layout.fixed.vertical,
        fill_space = true,
        spacing = dpi(8),
        {
            widget = wibox.container.margin,
            top = dpi(10),
            left = dpi(8),
            {
                layout = wibox.layout.align.horizontal,
                expand = "inside",
                back_button,
                title,
                reload_button,
            },
        },
        connected_network,
        layout
    },
}

return wifi_menu
