local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local bling = require("modules.bling")

local helpers = require("helpers")
local slider = require("ui.widget.slider")
local button = require("ui.widget.button")

local default_art = gfs.get_configuration_dir() .. "ui/icons/music.svg"

local art = wibox.widget {
    widget = wibox.widget.imagebox,
    image = default_art,
    valgin = "center",
    halgin = "left",
    horizontal_fit_policy = "auto",
    vertical_fit_policy = "auto",
    clip_shape = gears.shape.rounded_rect,
}

local background = wibox.widget {
    widget = wibox.container.background,
    bg = beautiful.popup_module_bg,
    shape = helpers.ui.rrect(20),
}

local player_widget = wibox.widget {
    markup = "No players",
    halign = "left",
    valign = "center",
    widget = wibox.widget.textbox
}

local title_widget = wibox.widget {
    widget = wibox.widget.textbox,
    font = "Inter Bold 14",
    ellipsize = "end",
    halign = "left",
    valign = "top",
    markup = "Nothing Playing",
}

local artist_widget = wibox.widget {
    widget = wibox.widget.textbox,
    font = "Inter Bold 9",
    halign = "left",
    valign = "center",
    markup = helpers.ui.colorize_text("Unknown Artist", beautiful.inactive),
}

local length = 0

local playerctl = bling.signal.playerctl.lib {
    update_on_activity = true,
    player = {"%any"}
}

local length_widget = wibox.widget {
    widget = wibox.widget.textbox,
    font = beautiful.mono_font .. "SemiBold 10",
    valign = "bottom",
    markup = "00:00",
}

local interval_widget = wibox.widget {
    widget = wibox.widget.textbox,
    font = beautiful.mono_font .. "SemiBold 10",
    valign = "top",
    markup = "00:00",
}

local time_widget = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(-2),
    {
        widget = wibox.container.margin,
        top = dpi(3),
        interval_widget,
    },
    {
        widget = wibox.widget.textbox,
        markup = helpers.ui.colorize_text("\u{e216}", beautiful.green),
        font = beautiful.mono_font .. "Bold 22",
    },
    {
        widget = wibox.container.margin,
        bottom = dpi(3),
        length_widget,
    },
}

local position_updated = false

local position_slider = slider {
    handle_border_width = 0,
    bar_shape = gears.shape.rounded_bar,
    bar_height = dpi(10),
    bar_color = beautiful.popup_bg,
    bar_active_color = beautiful.third_accent,
    maximum = 100,
    on_changed = function(val)
        if not position_updated then
            playerctl:set_position(val * length / 100, playerctl:get_active_player())
            position_updated = false
        end
    end,
}

-- Get Song Info
playerctl:connect_signal("metadata",
                       function(_, title, artist, album_path, album, new, player_name)

    local new_art = album_path ~= "" and album_path or default_art
    -- Set art widget
    art.image = new_art

    if album_path ~= "" then
        local extract_color = "convert " .. album_path .. " -resize 1x1 txt:- | grep -Po \"#[[:xdigit:]]{6}\""

        awful.spawn.easy_async_with_shell(extract_color, function(stdout)
            background:set_bg {
                type = "linear",
                from = { 0, 0 },
                to = { 150, 0 },
                stops = {
                    { 0, stdout },
                    { 1, gears.color.transparent }
                }
            }
        end)
    end

    -- Set player name, title and artist widgets
    player_widget:set_markup_silently(player_name)
    title_widget:set_markup_silently(title or "Nothing Playing")
    artist_widget:set_markup_silently(helpers.ui.colorize_text(artist == "" and "Unknown Artist" or artist, beautiful.inactive))

    -- filter out firefox since plasma-browser-integration
    -- automatically sends a notification itself
    if new and player_name ~= "firefox" then
        naughty.notification {
            title = title,
            app_name = player_name,
            image = album_path,
            markup = "<b>"..artist.."</b>\n"..album,
        }
    end
end)

playerctl:connect_signal("position", function(_, interval_sec, length_sec, _)
    if length_sec == 0 then length = 0; return end
    if not position_slider.pressed then
        position_updated = true
        position_slider:set_value(interval_sec / length_sec * 100)
    end
    length = length_sec

    local length_min = length_sec / 60
    length_min = (length_min < 10 and "0" or "") .. tostring(math.floor(length_min))
    length_sec = length_sec % 60
    length_sec = (length_sec < 10 and "0" or "") .. tostring(math.floor(length_sec))

    length_widget:set_markup_silently(length_min .. ":" .. length_sec)

    local interval_min = interval_sec / 60
    interval_min = (interval_min < 10 and "0" or "") .. tostring(math.floor(interval_min))
    interval_sec = interval_sec % 60
    interval_sec = (interval_sec < 10 and "0" or "") .. tostring(math.floor(interval_sec))

    interval_widget:set_markup_silently(interval_min .. ":" .. interval_sec)
end)

local prev = wibox.widget {
    text = "\u{e045}",
    font = beautiful.icon_font .. "20",
    widget = wibox.widget.textbox,
}

prev:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        playerctl:previous(playerctl:get_active_player())
    end
end)

local play_pause_text = wibox.widget {
    widget = wibox.widget.textbox,
    font = beautiful.icon_font .. "26",
    markup = helpers.ui.colorize_text("\u{e037}", beautiful.bg_normal),
    halign = "center",
    valign = "center",
}

local play_pause = button {
    shape = gears.shape.circle,
    bg = beautiful.button_bg_on,
    width = dpi(35),
    height = dpi(35),
    animate = false,
    on_release = function(b)
        if b == 1 then
            playerctl:play_pause(playerctl:get_active_player())
        end
    end,
    widget = play_pause_text,
}

playerctl:connect_signal("playback_status", function(_, playing, _)
    local new_markup = helpers.ui.colorize_text("\u{e037}", beautiful.bg_normal)
    if playing == true then
        new_markup = helpers.ui.colorize_text("\u{e034}", beautiful.bg_normal)
    end
    play_pause_text:set_markup_silently(new_markup)
end)

local next = wibox.widget {
    text = "\u{e044}",
    font = beautiful.icon_font .. "20",
    widget = wibox.widget.textbox,
}

next:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        playerctl:next(playerctl:get_active_player())
    end
end)

return function()
    return wibox.widget {
        widget = wibox.layout.stack,
        forced_height = dpi(160),
        background,
        {
            widget = wibox.container.margin,
            margins = dpi(10),
            {
                layout = wibox.layout.fixed.horizontal,
                fill_space = true,
                spacing = dpi(10),
                {
                    widget = wibox.container.constraint,
                    width = dpi(160),
                    strategy = "exact",
                    art,
                },
                {
                    layout = wibox.layout.fixed.vertical,
                    {
                        widget = wibox.container.constraint,
                        height = dpi(30),
                        strategy = "exact",
                        title_widget,
                    },
                    artist_widget,
                    time_widget,
                    {
                        widget = wibox.container.constraint,
                        height = dpi(25),
                        strategy = "exact",
                        position_slider,
                    },
                    {
                        widget = wibox.container.place,
                        {
                            layout = wibox.layout.fixed.horizontal,
                            spacing = dpi(5),
                            prev,
                            play_pause,
                            next,
                        }
                    },
                },
            }
        }
    }
end

