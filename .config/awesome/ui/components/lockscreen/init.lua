local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local pam = require("liblua_pam")

local helpers = require("helpers")
local button = require("ui.widget.button")
local inputbox = require("ui.widget.inputbox")

local capi = { awesome = awesome, screen = screen }

local lockscreen = {}

local widget
local password_prompt = inputbox.new {
    placeholder = "Enter Password...",
    hide_input = true,
    retry_on_escape = true,
    retry_on_fail = true,
    margins = dpi(10),
    shape = helpers.ui.prrect(20, 0, 0, 20),
    check_input = pam.auth_current_user,
    success_callback = function()
        for s in capi.screen do
            s.lockscreen.visible = false
        end
        _G.locked = false
        capi.awesome.emit_signal("lockscreen::unlock")
        -- hide the powermenu just in case the user locked the screen through the powermenu
        capi.awesome.emit_signal("powermenu::hide")
    end,
    fail_flash_hook = function(_, pos, current_color)
        if not widget then return end
        local btn = widget:get_children_by_id("btn")[1]
        btn.children[1]:set_border_color(current_color)
        btn.children[1]:set_border_width(pos*2)
    end
}

widget = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(2),
    {
        widget = wibox.container.constraint,
        width = dpi(200),
        strategy = "min",
        password_prompt,
    },
    {
        id = "btn",
        widget = wibox.container.place,
        halign = "right",
        button {
            shape = helpers.ui.prrect(0, 20, 20, 0),
            height = dpi(40),
            width = dpi(40),
            bg = beautiful.overlay,
            on_release = function()
                password_prompt:confirm()
            end,
            {
                widget = wibox.widget.textbox,
                markup = "\u{e5c8}",
                font = beautiful.icon_font .. "SemiBold 16",
                halign = "center",
                valign = "center",
            }
        }
    }
}

local function grab_password()
    password_prompt:start()
end

function lockscreen.activate()
    for s in capi.screen do
        s.lockscreen.visible = true
    end
    _G.locked = true
    -- the bar connects to this signal to hide the power button and taglist,
    -- and to raise itself so it's shown above the lockscreen
    capi.awesome.emit_signal("lockscreen::locked")

    grab_password()

    -- stop any music currently playing
    awful.spawn("playerctl pause")
end

capi.awesome.connect_signal("lockscreen::lock", lockscreen.activate)

local function power_btn(icon, col, action)
    return button {
        bg = beautiful.overlay,
        width = dpi(110),
        height = dpi(110),
        fg = col,
        hover_bg = col,
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
            }
        }
    }
end

return setmetatable(lockscreen, { __call = function(_, s)
    s.lockscreen = awful.popup {
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
                    widget = wibox.widget.textclock,
                    format = "%H %M",
                    font = beautiful.mono_font .. "SemiBold 34",
                    halign = "center",
                },
                {
                    widget = wibox.widget.textclock,
                    format = "%A, %d %B %Y",
                    font = beautiful.font .. "SemiBold 26",
                    halign = "center",
                },
                {
                    widget = wibox.container.place,
                    capi.screen.primary == s and widget or nil,
                },
                capi.screen.primary == s and {
                    widget = wibox.container.place,
                    {
                        layout = wibox.layout.fixed.horizontal,
                        spacing = dpi(30),
                        power_btn("\u{e8ac}", beautiful.red,     helpers.power.shutdown),
                        power_btn("\u{f053}", beautiful.orange,  helpers.power.reboot  ),
                        power_btn("\u{e9ba}", beautiful.magenta, helpers.power.logout  ),
                    }
                } or nil
            }
        },
    }

    return s.lockscreen
end})
