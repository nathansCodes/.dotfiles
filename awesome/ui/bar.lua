local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-------------------- widgets --------------------
local battery_widget = require("ui.widgets.battery")
local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")
local spotify_widget = require("awesome-wm-widgets.spotify-widget.spotify")
local network_widget = require("ui.widgets.network")
local bluetooth_widget = require("ui.widgets.bluetooth")
local keyboardlayout = require("ui.widgets.locale")

local control_panel = require("ui.control_panel")
local volume_widget = require("ui.widgets.volume")
local taglist = require("ui.widgets.taglist")

screen.connect_signal("request::desktop_decoration", function(s)
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    local textclock = wibox.container.place {
        widget = wibox.widget.textclock,
        format = "%H %M",
        timezone = "CET",
        refresh = 60,
        font = "CaskaydiaCoveNerdFontMono " .. "Medium 18",
    }

    local calendar = calendar_widget {
        radius = 20,
        previous_month_button = 1,
        next_month_button = 3,
    }
    textclock:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then calendar.toggle() end
    end)

    local volume = volume_widget {
        size = dpi(22),
        widget_type = 'icon',
    }

    volume:buttons( gears.table.join(
        awful.button({}, 2, function() volume_widget:toggle() end),
        awful.button({}, 4, function() volume_widget:inc() end),
        awful.button({}, 5, function() volume_widget:dec() end)
    ))

    local control_widget = wibox.container.background {
        layout = wibox.layout.fixed.horizontal,
        bg = beautiful.wibar_bg,
        {
            top = dpi(0),
            bottom = dpi(0),
            left = dpi(10),
            right = dpi(10),
            widget = wibox.container.margin,
            {
                layout = wibox.layout.align.horizontal,
                expand = "none",
                {
                    widget = wibox.container.margin,
                    margins = dpi(2),
                    network_widget(20),
                },
                {
                    widget = wibox.container.margin,
                    margins = dpi(2),
                    bluetooth_widget(20),
                },
                {
                    widget = wibox.container.margin,
                    margins = dpi(2),
                    volume,
                },
            },
        },
    }

    control_widget:set_shape(gears.shape.rounded_bar)

    control_widget:connect_signal("mouse::enter", function()
        control_widget.bg = {
            type = 'linear',
            from = { 0, 0 },
            to   = { 100, 0 },
            stops = {
                { 0, '#89b4fa' },
                { 1, '#cba6f7' },
            },
        }

        control_widget.fg = beautiful.bg_normal
    end)
    control_widget:connect_signal("mouse::leave", function()
        control_widget.bg = beautiful.bg_transparent
        control_widget.fg = beautiful.fg_normal
    end)
    control_widget:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            control_panel.toggle()
            s.mywibox.shape = s.mywibox.shape == beautiful.bar_shape and function(cr, w, h)
                gears.shape.partially_rounded_rect(cr, w, h, true, true, false, true, 16)
            end or beautiful.bar_shape
            s.mywibox.widget.shape = s.mywibox.widget.shape == beautiful.bar_shape and function(cr, w, h)
                gears.shape.partially_rounded_rect(cr, w, h, true, true, false, true, 16)
            end or beautiful.bar_shape
        end
    end)

    local power_button = wibox.widget {
        widget = wibox.container.margin,
        left = dpi(8),
        right = dpi(6),
        forced_width = dpi(36),
        {
            widget = wibox.widget.textbox,
            text = "⏻",
            font = beautiful.font .. " Regular 20",
        },
    }

    power_button:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            awful.spawn.with_shell(gfs.get_configuration_dir() .. "../rofi/scripts/powermenu_t2")
        end
    end)

    client.connect_signal("property::fullscreen", function(c)
        s.mywibox.ontop = not c.fullscreen
    end)

    -- Create the wibox
    s.mywibox = awful.wibar {
        screen = s,
        type = "dock",
        height = dpi(32),
        width = dpi(1900),
        ontop = true,
        shape = beautiful.bar_shape,
        visible = true,
        bg = "#00000000",
    }

    s.mywibox:struts { top = s.mywibox.height - 4, bottom = 0, left = 0, right = 0 }

    s.mywibox:setup {
        widget = wibox.container.background,
        shape_border_width = dpi(2),
        shape_border_color = beautiful.wibar_border_color,
        shape = s.mywibox.shape,
        bg = beautiful.bg_transparent,
        {
            layout = wibox.layout.align.horizontal,
            expand = "inside",
            {
                widget = wibox.container.background,
                shape = function(cr, w, h)
                    gears.shape.transform(gears.shape.rectangular_tag)
                        : rotate_at(20, 16, math.pi) (cr, w, h, -9)
                end,
                bg = beautiful.wibar_border_color,
                fg = beautiful.bg_normal,
                forced_width = dpi(40),
                power_button,
            },
            {
                layout = wibox.container.margin,
                left = dpi(-9),
                right = dpi(-9),
                {
                    widget = wibox.container.background,
                    shape = s.mywibox.shape,
                    border_width = dpi(2),
                    border_color = beautiful.wibar_border_color,
                    border_strategy = "inner",
                    bg = beautiful.wibar_bg .. beautiful.fully_transparent,
                    fg = beautiful.fg_normal,
                    {
                        layout = wibox.layout.align.horizontal,
                        expand = "none",
                        {
                            layout = wibox.layout.fixed.horizontal,
                            spacing = dpi(7),
                            taglist(s),
                            s.mypromptbox,
                        },
                        {
                            layout = wibox.layout.fixed.horizontal,
                            textclock,
                        },
                        {
                            layout = wibox.layout.fixed.horizontal,
                            spacing = dpi(5),
                            spotify_widget(),
                            control_widget,
                            battery_widget(),
                            keyboardlayout { "us", "de" },
                        },
                    }
                }
            },
            {
                widget = wibox.container.background,
                shape = function(cr, w, h)
                    gears.shape.rectangular_tag(cr, w, h, -9)
                end,
                forced_width = dpi(50),
                bg = beautiful.wibar_border_color,
                fg = beautiful.bg_normal,
                {
                    widget = wibox.container.margin,
                    top = dpi(1),
                    bottom = dpi(1),
                    left = dpi(12),
                    awful.widget.layoutbox(),
                }
            },
        }
    }
end)

