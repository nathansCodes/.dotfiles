local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-------------------- widgets --------------------
local battery_widget = require("ui.widget.battery")
local network_widget = require("ui.widget.network")
local bluetooth_widget = require("ui.widget.bluetooth")
local volume_widget = require("ui.widget.volume")
local keyboardlayout = require("ui.widget.locale")
local taglist = require("ui.widget.taglist")
local button = require("ui.widget.button")

-------------------- panels ---------------------
local right_panel = require("ui.components.right_panel")
--local central_panel = require("ui.central_panel")

screen.connect_signal("request::desktop_decoration", function(s)
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    local textclock = button {
        on_release = function(_, _, _, _, b)
            if b ~= 1 then return end
            --central_panel:toggle()
        end,
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

    local volume = volume_widget { size = 22 }

    volume:buttons( gears.table.join(
        awful.button({}, 2, function() volume_widget:toggle() end),
        awful.button({}, 4, function() volume_widget:inc() end),
        awful.button({}, 5, function() volume_widget:dec() end)
    ))

    local right_panel_button = button {
        shape = gears.shape.rounded_bar,
        on_release = function(_, _, _, _, b)
            if b == 1 then
                s.right_panel:toggle()
            end
        end,
        widget = {
            widget = wibox.container.margin,
            top = dpi(0),
            bottom = dpi(0),
            left = dpi(10),
            right = dpi(10),
            {
                layout = wibox.layout.align.horizontal,
                expand = "none",
                network_widget(22),
                bluetooth_widget(22),
                volume,
            },
        },
    }

    local power_button = wibox.widget {
        widget = wibox.container.margin,
        left = dpi(4),
        buttons = {
            awful.button({}, 1, function()
                awful.spawn(gfs.get_configuration_dir() .. "../rofi/scripts/powermenu")
            end),
        },
        {
            widget = wibox.container.background,
            fg = beautiful.error,
            {
                widget = wibox.widget.textbox,
                text = "\u{f8c7}",
                font = beautiful.icon_font .. "Bold 22",
            }
        },
    }

    local systray = button {
        right = false,
        left = true,
        top = false,
        bottom = false,
        bg_off = gears.color.transparent,
        fg_off = beautiful.text,
        fg_on = beautiful.accent,
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
                wibox.widget.systray(),
            },
            {
                widget = wibox.widget.textbox,
                text = "\u{e5cc}",
                font = beautiful.icon_font .. "Regular 20",
            },
        },
    }

    client.connect_signal("property::fullscreen", function(c)
        s.bar.ontop = not c.fullscreen
    end)

    -- Create the wibox
    s.bar = awful.wibar {
        screen = s,
        type = "dock",
        height = dpi(36),
        ontop = true,
        visible = true,
    }

    s.bar:struts { top = s.bar.y + s.bar.height, bottom = 0, left = 0, right = 0 }

    s.bar:setup {
        widget = wibox.container.background,
        bg = beautiful.bg_normal,
        {
            widget = wibox.container.margin,
            margins = dpi(4),
            {
                layout = wibox.layout.align.horizontal,
                expand = "none",
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(7),
                    power_button,
                    {
                        widget = wibox.container.margin,
                        left = dpi(1),
                        taglist(s),
                    },
                    s.mypromptbox,
                },
                {
                    layout = wibox.layout.fixed.horizontal,
                    textclock,
                },
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(5),
                    systray,
                    right_panel_button,
                    battery_widget(),
                    keyboardlayout(),
                    {
                        widget = wibox.container.margin,
                        top = dpi(1),
                        bottom = dpi(1),
                        right = dpi(8),
                        awful.widget.layoutbox(),
                    }
                },
            }
        }
    }

    right_panel(s)
end)

