local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local bling = require("bling")

local art = wibox.widget {
    image = "default_image.png",
    resize = true,
    widget = wibox.widget.imagebox,
    upscale = true,
}

local name_widget = wibox.widget {
    markup = 'No players',
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local title_widget = wibox.widget {
    markup = 'Nothing Playing',
    font = "Inter Regular 12",
    ellipsize = "end",
    forced_height = dpi(22),
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local artist_widget = wibox.widget {
    markup = 'Nothing Playing',
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

-- Get Song Info
local playerctl = bling.signal.playerctl.lib {
    update_on_activity = true,
    player = {"%any"}
}
playerctl:connect_signal("metadata",
                       function(_, title, artist, album_path, album, new, player_name)
    -- Set art widget
    art:set_image(gears.surface.load_uncached(album_path))

    -- Set player name, title and artist widgets
    name_widget:set_markup_silently(player_name)
    title_widget:set_markup_silently(title)
    artist_widget:set_markup_silently(artist)
end)

local progressbar = wibox.widget {
    widget = wibox.widget.progressbar,
    shape = gears.shape.rounded_bar,
    bar_shape = gears.shape.rounded_bar,
    height = 8,
    value = 1,
    background_color = beautiful.bg_normal,
    color = {
        type  = "linear",
        from  = { 0  , 0 },
        to    = { 100, 100 },
        stops = {
            { 0,   beautiful.forth_accent },
            { 0.5, beautiful.second_accent },
            { 1,   beautiful.third_accent }
        }
    },
}

playerctl:connect_signal("position", function(_, interval_sec, length_sec, _)
    progressbar.value = (interval_sec/length_sec) * 100
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

local play_pause = wibox.widget {
    text = "\u{e037}",
    font = beautiful.icon_font .. "20",
    widget = wibox.widget.textbox,
}

play_pause:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        playerctl:play_pause(playerctl:get_active_player())
    end
end)

playerctl:connect_signal("playback_status", function(_, playing, _)
    if playing == true then
        play_pause:set_text("\u{e034}")
    else
        play_pause:set_text("\u{e037}")
    end
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
        layout = wibox.layout.stack,
        margins = dpi(0),
        bg = beautiful.bg_transparent,
        shape = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 20)
        end,
        {
            layout = wibox.layout.align.horizontal,
            expand = 'none',
            nil,
            art,
            nil
        },
        {
            widget = wibox.container.background,
            bg = beautiful.bg_focus .. beautiful.transparent,
            shape = function(cr, w, h)
                gears.shape.rounded_rect(cr, w, h, 20)
            end,
            {
                widget = wibox.container.margin,
                margins = dpi(10),
                {
                    layout = wibox.layout.align.vertical,
                    expand = "inside",
                    title_widget,
                    {
                        widget = wibox.container.margin,
                        left = dpi(30),
                        right = dpi(30),
                        {
                            layout = wibox.layout.align.horizontal,
                            expand = "none",
                            prev,
                            play_pause,
                            next,
                        }
                    },
                    progressbar,
                }
            }
        }
    }
end
