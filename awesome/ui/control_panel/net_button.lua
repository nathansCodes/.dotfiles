local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local net_icon = require("ui.widgets.network")
require("helpers.widget")

local on

local stop_toggle = false

return function(size)
    local button = wibox.widget {
        id = "icon_bg",
        widget = wibox.container.background,
        shape = gears.shape.circle,
        bg = beautiful.button_bg_off,
        wibox.widget {
            widget = wibox.container.place,
            valgin = "center",
            halgin = "center",
            content_fill_horizontal = true,
            buttons = {
                awful.button({ }, 1, function()
                    if stop_toggle then return end
                    if on ~= nil then
                        awful.spawn.once("nmcli n off")
                    else
                        awful.spawn.once("nmcli n on")
                    end
                end)
            },
            net_icon(size, false),
        }
    }

    awful.widget.watch("/home/nathan/.dotfiles/scripts/check_network.sh", 1, function(_, stdout)
        on = stdout:match("disconnected")
            or stdout:match("connecting")
            or stdout:match("connected")

        if on ~= nil then
            button.bg = beautiful.button_bg_on
            button.fg = beautiful.bg_focus
        else
            button.bg = beautiful.button_bg_off
            button.fg = beautiful.fg_normal
        end
    end)

    local old_cursor, old_wibox

    button:connect_signal( 'mouse::enter', function()
        local w = _G.mouse.current_wibox
        if w then
            old_cursor, old_wibox = w.cursor, w
            w.cursor = 'hand1'
        end
    end)

    button:connect_signal( 'mouse::leave', function()
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)

    local expand_icon = [[
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg
   width="31.999998"
   height="31.999998"
   viewBox="0 0 8.4666661 8.4666661"
   version="1.1"
   id="svg1"
   inkscape:export-filename="tri.svg"
   inkscape:export-xdpi="96"
   inkscape:export-ydpi="96"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:svg="http://www.w3.org/2000/svg">
  <sodipodi:namedview
     id="namedview1"
     pagecolor="#505050"
     bordercolor="#eeeeee"
     borderopacity="1"
     inkscape:showpageshadow="0"
     inkscape:pageopacity="0"
     inkscape:pagecheckerboard="false"
     inkscape:deskcolor="#505050"
     inkscape:document-units="mm" />
  <defs
     id="defs1" />
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1">
    <path
       id="path1"
       style="fill:]] .. beautiful.text .. [[;stroke:#000000;stroke-width:0"
       inkscape:transform-center-x="1.8680052"
       inkscape:transform-center-y="-2.1091618"
       d="M 8.454228,4.5280959 C 8.4528462,4.8542139 8.3045299,7.8218123 8.1423929,8.1047245 7.980138,8.3876576 4.4069765,8.445489 4.0809139,8.4465701 3.7548229,8.4476542 0.18122271,8.4134978 0.0172542,8.1316822 -0.14668085,7.8497876 3.1245255,4.8307871 3.7657887,4.2737933 4.4124971,3.7120647 7.8098203,1.0827013 8.1358848,1.0816475 c 0.3261,-0.00108 0.319331,3.1783024 0.3183043,3.4464746 z"
       sodipodi:nodetypes="sssssss" />
  </g>
</svg> ]]

    local expand_button = wibox.widget {
        id = "icon",
        widget = wibox.widget.imagebox,
        valign = "bottom",
        halign = "right",
        forced_width = dpi(14),
        forced_height = dpi(14),
        image = expand_icon,
        buttons = {
            awful.button({ }, 1, function()
                awesome.emit_signal("control_panel::toggle_wifi_menu")
            end)
        }
    }

    expand_button:connect_signal( 'mouse::enter', function()
        stop_toggle = true
    end)

    expand_button:connect_signal( 'mouse::leave', function()
        stop_toggle = false
    end)

    local widget = wibox.widget {
        layout = wibox.layout.stack,
        button,
        wibox.widget {
            widget = wibox.container.place,
            valign = "bottom",
            halign = "right",
            expand_button,
        },
    }

    return widget
end
