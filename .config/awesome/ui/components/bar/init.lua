local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local settings = require("config.user_settings")

-------------------- widgets --------------------
local battery_widget = require("ui.widget.battery")
local network_widget = require("ui.widget.network")
local bluetooth_widget = require("ui.widget.bluetooth")
local volume_widget = require("ui.widget.volume")
local keyboardlayout = require("ui.widget.keyboard_layout")
local taglist = require("ui.components.bar.taglist")
local button = require("ui.widget.button")

local helpers = require("helpers")

local capi = { awesome = awesome, client = client }

return function(s)
    local power_button = wibox.widget {
        widget = wibox.widget.textbox,
        markup = helpers.ui.colorize_text("\u{f8c7}", beautiful.error),
        font = beautiful.icon_font .. "Bold 22",
        buttons = {
            awful.button({}, 1, function()
                capi.awesome.emit_signal("powermenu::show")
            end),
        },
    }

    local taglist = taglist(s)

    s.mypromptbox = awful.widget.prompt()

    local textclock = button {
        shape = gears.shape.rounded_bar,
        width = dpi(100),
        widget = {
            id = "text",
            widget = wibox.widget.textclock,
            format = "%H %M",
            timezone = "CET",
            halign = "center",
            refresh = 60,
            font = beautiful.mono_font .. "18",
        }
    }

    local systray = button {
        on_release = function(_, widget)
            local tray = widget.children[1]
            tray.visible = not tray.visible
            widget.children[2]:set_text(tray.visible and "\u{e5cb}" or "\u{e5cc}")
        end,
        widget = wibox.widget {
            layout = wibox.layout.fixed.horizontal,
            {
                widget = wibox.container.background,
                visible = false,
                {
                    widget = wibox.widget.systray,
                    screen = "primary",
                }
            },
            {
                widget = wibox.widget.textbox,
                text = "\u{e5cc}",
                font = beautiful.icon_font .. "Regular 20",
            },
        },
    }

    local volume = volume_widget { size = 22, device = settings.device.audio }

    volume:buttons( gears.table.join(
        awful.button({}, 2, function() volume_widget:toggle() end),
        awful.button({}, 4, function() volume_widget:inc() end),
        awful.button({}, 5, function() volume_widget:dec() end)
    ))

    local system_stats = button {
        shape = gears.shape.rounded_bar,
        left = dpi(4),
        widget = {
            layout = wibox.layout.align.horizontal,
            expand = "none",
            network_widget(22),
            bluetooth_widget(22),
            volume,
        },
    }

    local screenshot_ticker = wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.font .. "SemiBold 12",
    }

    capi.awesome.connect_signal("screenshot::countdown_tick", function(_, remaining)
        if remaining ~= 0 then
            screenshot_ticker:set_text(tostring(remaining))
        else
            screenshot_ticker:set_text("")
        end
    end)

    local layoutbox = {
        widget = wibox.container.place,
        awful.widget.layoutbox(),
    }

    capi.client.connect_signal("property::fullscreen", function(c)
        s.bar.ontop = not c.fullscreen
    end)

    -- Create the wibox
    s.bar = awful.wibar {
        screen = s,
        type = "dock",
        height = dpi(56, s),
        shape = function(cr, w, h)
            cr:move_to(0, 0)
            cr:line_to(w, 0)

            local radius = dpi(20)
            cr:arc_negative( w-radius, h, radius,    math.pi*2 , 3*(math.pi/2) )
            cr:arc_negative(   radius, h, radius, 3*(math.pi/2),    math.pi    )

            cr:close_path()
        end,
        bg = gears.color.transparent,
        ontop = true,
        visible = true,
    }

    s.bar:struts { top = dpi(36, s), bottom = 0, left = 0, right = 0 }

    s.bar:setup {
        widget = wibox.container.background,
        bg = beautiful.bg_normal,
        {
            widget = wibox.container.margin,
            left = dpi(10),
            right = dpi(10),
            top = dpi(4),
            bottom = dpi(24),
            {
                layout = wibox.layout.align.horizontal,
                expand = "none",
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(8),
                    power_button,
                    taglist,
                    s.mypromptbox,
                },
                {
                    layout = wibox.layout.fixed.horizontal,
                    textclock,
                },
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(10),
                    screenshot_ticker,
                    systray,
                    system_stats,
                    battery_widget(),
                    keyboardlayout(),
                    layoutbox,
                },
            }
        }
    }

    capi.awesome.connect_signal("lockscreen::locked", function()
        -- I think this is the only way to get the bar to appear above the lockscreen
        s.bar.visible = false
        s.bar.visible = true
        -- reset struts so they don't get reset
        -- automatically to something we don't want
        s.bar:struts { top = dpi(36, s), bottom = 0, left = 0, right = 0 }
        power_button.visible = false
        taglist.visible = false
        systray.visible = false
        layoutbox.visible = false
    end)

    capi.awesome.connect_signal("lockscreen::unlock", function()
        power_button.visible = true
        taglist.visible = true
        systray.visible = true
        layoutbox.visible = true
    end)
end

