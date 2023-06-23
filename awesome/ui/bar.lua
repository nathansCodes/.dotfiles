local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")

-------------------- widgets --------------------
local battery_widget = require("awesome-wm-widgets.battery-widget.battery")
local volume_widget = require("awesome-wm-widgets.volume-widget.volume")
local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")
local logout_popup = require("awesome-wm-widgets.logout-popup-widget.logout-popup")
local brightness_widget = require("awesome-wm-widgets.brightness-widget.brightness")
local spotify_widget = require("awesome-wm-widgets.spotify-widget.spotify")
local network_widget = require("ui.widgets.network")
local bluetooth_widget = require("ui.widgets.bluetooth")

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

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
        local tag_icons_urgent = gfs.get_configuration_dir() .. "ui/icons/tags/urgent/"

        local set_icon = function(name)
            local tag = awful.tag.find_by_name(s, name)
            local icon

            if tag.urgent == true then
                icon = tag_icons_urgent .. name .. ".svg"
            elseif tag.selected == true then
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
        screen = s,
        buttons = taglist_buttons,
        filter = awful.widget.taglist.filter.all,
        style = {
            shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, 20)
            end,
        },
        layout = {
            layout = wibox.layout.fixed.horizontal,
            spacing = 2,
        },
        widget_template = {
            {
                {
                    {
                        {
                            id     = "icon_role",
                            widget = wibox.widget.imagebox,
                            vertical_fit_policy = "none",
                            horizontal_fit_policy = "none",
                            valign = "center",
                        },
                        margins = 4,
                        widget  = wibox.container.margin,
                    },
                    {
                        id     = "text_role",
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                left  = 14,
                right = 14,
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

    local control_widget = wibox.widget {
        layout = wibox.layout.align.horizontal,
        network_widget(),
        bluetooth_widget,
        volume_widget {
            font = "CaskaydiaCoveNerdFontMono Regular 12",
            widget_type = 'icon',
        },
    }

    -- Create the wibox
    s.mywibox = awful.wibar {
        position = "top",
        screen = s,
        height = 32,
        width = s.geometry.width * 0.99,
        border_width = 6,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 20)
        end,
    }

    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        {
            layout = wibox.layout.fixed.horizontal,
            spacing = 7,
            background = beautiful.bg_normal,
            logout_popup.widget {
                text_color = beautiful.wibar_fg,
                accent_color = beautiful.bg_focus,
                icon = gfs.get_configuration_dir() .. "ui/icons/power.svg",
            },
            taglist,
            s.mypromptbox,
        },
        {
            layout = wibox.layout.fixed.horizontal,
            textclock,
        },
        {
            layout = wibox.layout.fixed.horizontal,
            spacing = 7,
            spotify_widget(),
            control_widget,
            battery_widget {
                font = "CaskaydiaCoveNerdFontMono Regular 12",
                path_to_icons = "/usr/share/icons/Rose-Pine/status/symbolic/",
                show_current_level = true,
                display_notification = true,
            },
            brightness_widget {
                font = "CaskaydiaCoveNerdFontMono Regular 12",
                type = "icon_and_text",
                program = "light",
                percentage = true,
            },
            mykeyboardlayout,
        },
    }
end)

