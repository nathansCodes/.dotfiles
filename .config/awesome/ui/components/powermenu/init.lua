local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local button = require("ui.widget.button")
local helpers = require("helpers")
local power = helpers.power

local capi = { awesome = awesome, screen = screen }

local powermenu = {}

function powermenu.hide()
    for _, s in ipairs(capi.screen) do
        s.powermenu.visible = false
    end
    awful.keygrabber.stop()
    for _, b in ipairs(powermenu.buttons.children) do
        b:unhover()
    end
end

local grabber = awful.keygrabber {
    keybindings = {},
    stop_key = "Escape",
    stop_event = "release",
    stop_callback = powermenu.hide
}

function powermenu.show()
    grabber:start()

    for _, s in ipairs(capi.screen) do
        s.powermenu.visible = true
    end
end

local function create_button(icon, color, key, action)
    local b = button {
        bg = beautiful.overlay,
        width = dpi(120),
        height = dpi(120),
        fg = color,
        hover_bg = color,
        hover_fg = beautiful.overlay,
        on_release = action,
        {
            widget = wibox.container.place,
            {
                layout = wibox.layout.fixed.vertical,
                spacing = dpi(5),
                {
                    widget = wibox.widget.textbox,
                    font   = beautiful.icon_font .. "Bold 34",
                    valign = "bottom",
                    halign = "center",
                    text   = icon,
                },
                {
                    widget = wibox.widget.textbox,
                    font   = beautiful.font .. "Regular 14",
                    valign = "center",
                    halign = "center",
                    text   = key,
                }
            }
        }
    }
    grabber:add_keybinding(awful.key {
        modifiers  = {},
        key        = key:lower(),
        on_press   = function() b:hover() end,
        on_release = function()
            b:unhover()
            awful.keygrabber.stop()
            action()
        end,
    })
    return b
end

powermenu.buttons = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(30),
    create_button("\u{e8ac}", beautiful.red    , "S", power.shutdown),
    create_button("\u{f053}", beautiful.orange , "R", power.reboot  ),
    create_button("\u{e897}", beautiful.blue   , "K", power.lock    ),
    create_button("\u{e9ba}", beautiful.magenta, "L", power.logout  ),
}

capi.awesome.connect_signal("powermenu::show", powermenu.show)
capi.awesome.connect_signal("powermenu::hide", powermenu.hide)

local username = helpers.str.upper_first_letter(os.getenv("USER") or "")

return setmetatable(powermenu, { __call = function(_, s)
    s.powermenu = awful.popup {
        type = "splash",
        ontop = true,
        visible = false,
        screen = s,
        placement = function(d)
            awful.placement.maximize(d, {
                honor_workarea = false,
                honor_padding = false,
            })
        end,
        bg = beautiful.surface,
        widget = {
            widget = wibox.container.place,
            {
                layout = wibox.layout.fixed.vertical,
                spacing = dpi(25),
                {
                    widget = wibox.widget.textbox,
                    font = beautiful.font .. "SemiBold 26",
                    text = "Goodbye, " .. username,
                    halign = "center",
                },
                {
                    widget = wibox.container.place,
                    capi.screen.primary == s and powermenu.buttons or nil,
                }
            }
        },
    }

    return s.powermenu
end})
