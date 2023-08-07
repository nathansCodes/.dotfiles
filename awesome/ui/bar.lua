local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-------------------- widgets --------------------
local battery_widget = require("awesome-wm-widgets.battery-widget.battery")
local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")
local spotify_widget = require("awesome-wm-widgets.spotify-widget.spotify")
local network_widget = require("ui.widgets.network")
local bluetooth_widget = require("ui.widgets.bluetooth")
local keyboardlayout = require("ui.widgets.locale")

local control_panel = require("ui.control_panel")
local volume_widget = require("ui.widgets.volume")

local taglist_buttons = gears.table.join(
	awful.button({ }, 1, function(t) t:view_only() end),
	awful.button({ modkey }, 1, function(t)
	    if client.focus then
	        client.focus:move_to_tag(t)
	    end
	end),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
	    if client.focus then
	        client.focus:toggle_tag(t)
	    end
	end),
	awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)


screen.connect_signal("request::desktop_decoration", function(s)
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    screen.connect_signal("tag::history::update", function(s)
        local tag_icons_normal = gfs.get_configuration_dir() .. "ui/icons/tags/normal/"
        local tag_icons_focus = gfs.get_configuration_dir() .. "ui/icons/tags/focus/"
        -- TODO: local tag_icons_urgent = gfs.get_configuration_dir() .. "ui/icons/tags/urgent/"

        local set_icon = function(name)
            local tag = awful.tag.find_by_name(s, name)
            local icon

            if tag.selected then
                icon = tag_icons_focus .. name .. ".svg"
            else
                icon = tag_icons_normal .. name .. ".svg"
            end

            tag.icon = icon
        end

        set_icon("main")
        set_icon("web")
        set_icon("file")
        set_icon("chat")
        set_icon("misc")
    end)

    local taglist = awful.widget.taglist {
        screen  = s,
        buttons = taglist_buttons,
        filter  = awful.widget.taglist.filter.all,
        style   = {
            shape = gears.shape.rounded_bar,
            shape_border_width = dpi(0),
            shape_border_width_focus = dpi(0),
        },
        layout  = {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(6),
        },
        widget_template = {
            {
                {
                    {
                        {
                            {
                                id     = "icon_role",
                                widget = wibox.widget.imagebox,
                                vertical_fit_policy = "fit",
                                horizontal_fit_policy = "fit",
                                valign = "center",
                                align = "center",
                            },
                            margins = dpi(3),
                            widget  = wibox.container.margin,
                        },
                        layout = wibox.layout.align.horizontal,
                        expand = "outside",
                    },
                    layout = wibox.layout.fixed.vertical
                },
                top    = dpi(2),
                bottom = dpi(2),
                left   = dpi(6),
                right  = dpi(6),
                widget = wibox.container.margin
            },
            id     = "background_role",
            widget = wibox.container.background,
        },
    }

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
        control_widget.bg = beautiful.bg_focus
        control_widget.shape_border_width = 2
    end)
    control_widget:connect_signal("mouse::leave", function()
        control_widget.bg = beautiful.transparency
        control_widget.shape_border_width = 0
    end)
    control_widget:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            control_panel.toggle()
            s.mywibox.shape = s.mywibox.shape == gears.shape.rounded_bar and function(cr, w, h)
                gears.shape.partially_rounded_rect(cr, w, h, true, true, false, true, 16)
            end or gears.shape.rounded_bar
            s.mywibox.widget.shape = s.mywibox.widget.shape == gears.shape.rounded_bar and function(cr, w, h)
                gears.shape.partially_rounded_rect(cr, w, h, true, true, false, true, 16)
            end or gears.shape.rounded_bar
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

    -- Create the wibox
    s.mywibox = awful.wibar {
        screen = s,
        type = "dock",
        height = dpi(32),
        width = s.geometry.width * 0.99,
        ontop = false,
        shape = gears.shape.rounded_bar,
        visible = true,
        bg = beautiful.wibar_bg,
    }

    s.mywibox:struts { top = s.mywibox.height - 4, bottom = 0, left = 0, right = 0 }

    s.mywibox:setup {
        widget = wibox.container.background,
        shape_border_width = dpi(2),
        shape_border_color = beautiful.border_focus,
        shape = s.mywibox.shape,
        bg = beautiful.accent,
        fg = beautiful.bg_normal,
        {
            layout = wibox.layout.align.horizontal,
            expand = "inside",
            power_button,
            {
                widget = wibox.container.background,
                shape = gears.shape.rounded_bar,
                border_width = 2,
                border_color = beautiful.accent,
                bg = beautiful.bg_normal,
                fg = beautiful.fg_normal,
                {
                    layout = wibox.layout.align.horizontal,
                    expand = "none",
                    {
                        layout = wibox.layout.fixed.horizontal,
                        spacing = dpi(7),
                        taglist,
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
                        {
                            widget = wibox.container.margin,
                            top = dpi(2),
                            bottom = dpi(2),
                            control_widget,
                        },
                        battery_widget {
                            font = "CaskaydiaCoveNerdFontMono Regular 12",
                            path_to_icons = "/usr/share/icons/Rose-Pine/status/symbolic/",
                            show_current_level = true,
                            display_notification = true,
                        },
                        keyboardlayout { "us", "de" },
                    },
                }
            },
            {
                widget = wibox.container.background,
                bg = beautiful.accent,
                {
                    widget = wibox.container.margin,
                    top = dpi(1),
                    bottom = dpi(1),
                    left = dpi(3),
                    right = dpi(8),
                    awful.widget.layoutbox(),
                }
            },
        }
    }
end)

