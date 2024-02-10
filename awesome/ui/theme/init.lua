local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")
local awful = require("awful")
local gfs = gears.filesystem
local themes_path = gfs.get_themes_dir()
local conf_dir = gfs.get_configuration_dir()
local icons_path = conf_dir .. "ui/icons/"

local theme = require("ui.theme.apply_theme")

theme.icon_font = "Material Symbols Rounded "
theme.mono_font = "Inter Mono "
theme.font = "Inter "

theme.bg_normal          = theme.base
theme.bg_focus           = theme.surface
theme.bg_urgent          = theme.highlight_med
theme.bg_minimize        = theme.ignored

theme.fg_normal          = theme.text
theme.fg_focus           = theme.text
theme.fg_unfocus         = theme.inactive
theme.fg_urgent          = theme.red
theme.fg_minimize        = theme.highlight_high

theme.wibar_fg           = theme.white
theme.wibar_bg           = theme.base
theme.wibar_border_color = theme.accent

theme.useless_gap        = dpi(8)
theme.border_width       = dpi(0)
theme.gap_single_client  = true

theme.button_bg_off      = theme.highlight_med
theme.button_bg_on       = theme.accent

theme.button_fg_off      = theme.text
theme.button_fg_on       = theme.bg_normal

theme.taglist_fg_normal    = theme.bg_normal
theme.taglist_fg_focus     = theme.bg_normal
theme.taglist_fg_occupied  = theme.bg_normal
theme.taglist_fg_empty     = theme.bg_normal
theme.taglist_fg_urgent    = theme.bg_normal
theme.taglist_bg_empty     = theme.inactive
theme.taglist_bg_occupied  = theme.text
theme.taglist_bg_urgent    = theme.error
theme.taglist_bg_focus     = theme.accent
theme.taglist_bg_normal    = gears.color.transparent
theme.taglist_font         = theme.font .. "Bold 11"

theme.tasklist_bg_focus    = theme.surface
theme.tasklist_bg_normal   = theme.base
theme.tasklist_bg_minimize = theme.overlay

theme.popup_bg             = theme.base
theme.popup_module_bg      = theme.overlay

theme.hotkeys_bg           = theme.bg_normal
theme.hotkeys_border_color = theme.border_focus
theme.hotkeys_modifiers_fg = theme.fg_normal
theme.hotkeys_shape        = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, 20)
end

theme.tag_preview_widget_border_radius = dpi(7)
theme.tag_preview_widget_border_width = dpi(2)
theme.tag_preview_widget_border_color = theme.border_focus
theme.tag_preview_widget_bg = theme.bg_normal
theme.tag_preview_widget_margin = dpi(4)
theme.tag_preview_client_border_radius = dpi(7)
theme.tag_preview_client_border_width = dpi(1)
theme.tag_preview_client_border_color = theme.border_normal

theme.task_preview_widget_border_radius = 14        -- Border radius of the widget (With AA)
theme.task_preview_widget_bg = theme.base          -- The bg color of the widget
theme.task_preview_widget_border_width = 0         -- The border width of the widget
theme.task_preview_widget_margin = 8               -- The margin of the widget

theme.prompt_bg = gears.color.transparent

theme.tooltip_shape = gears.shape.rounded_rect
theme.tooltip_border_width = dpi(2)
theme.tooltip_border_color = {
    type = 'linear',
    from = { 0, 0 },
    to = { 100, 100 },
    stops = {
        { 0, theme.red },
        { 1, theme.blue },
    }
}
theme.tooltip_bg = theme.bg_normal
theme.tooltip_margin = dpi(4)

theme.notification_height = dpi(150)
theme.notification_width = dpi(350)
theme.notification_position = "top_middle"

theme.menu_submenu_icon = themes_path.."default/submenu.png"
theme.menu_height       = dpi(15)
theme.menu_width        = dpi(100)

local recolor = gears.color.recolor_image

theme.layout_fairh      = recolor(themes_path.."default/layouts/fairhw.png",      theme.text)
theme.layout_fairv      = recolor(themes_path.."default/layouts/fairvw.png",      theme.text)
theme.layout_floating   = recolor(themes_path.."default/layouts/floatingw.png",   theme.text)
theme.layout_magnifier  = recolor(themes_path.."default/layouts/magnifierw.png",  theme.text)
theme.layout_max        = recolor(themes_path.."default/layouts/maxw.png",        theme.text)
theme.layout_fullscreen = recolor(themes_path.."default/layouts/fullscreenw.png", theme.text)
theme.layout_tilebottom = recolor(themes_path.."default/layouts/tilebottomw.png", theme.text)
theme.layout_tileleft   = recolor(themes_path.."default/layouts/tileleftw.png",   theme.text)
theme.layout_tile       = recolor(themes_path.."default/layouts/tilew.png",       theme.text)
theme.layout_tiletop    = recolor(themes_path.."default/layouts/tiletopw.png",    theme.text)
theme.layout_spiral     = recolor(themes_path.."default/layouts/spiralw.png",     theme.text)
theme.layout_dwindle    = recolor(themes_path.."default/layouts/dwindlew.png",    theme.text)
theme.layout_cornernw   = recolor(themes_path.."default/layouts/cornernww.png",   theme.text)
theme.layout_cornerne   = recolor(themes_path.."default/layouts/cornernew.png",   theme.text)
theme.layout_cornersw   = recolor(themes_path.."default/layouts/cornersww.png",   theme.text)
theme.layout_cornerse   = recolor(themes_path.."default/layouts/cornersew.png",   theme.text)

theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

theme.icon_theme = "/usr/share/icons/Papirus-Dark/index.theme"

theme.wallpaper = theme.path.."wallpaper.png"

if not gfs.file_readable(theme.wallpaper) then
    theme.wallpaper = theme.path.."wallpaper.jpg"
end
if not gfs.file_readable(theme.wallpaper) then
    theme.wallpaper = theme.path.."wallpaper.jpeg"
end
if not gfs.file_readable(theme.wallpaper) then
    theme.wallpaper = theme.path.."wallpaper.svg"
end

local function set_wallpaper(s)
    awful.wallpaper {
        screen = s,
        bg = theme.bg_normal,
        widget = wibox.widget {
            widget = wibox.container.margin,
            top = dpi(36),
            {
                widget = wibox.container.background,
                shape = function(cr, w, h)
                    gears.shape.rounded_rect(cr, w, h, 20)
                end,
                {
                    widget = wibox.container.margin,
                    top = dpi(-36),
                    {
                        widget = wibox.widget.imagebox,
                        image = theme.wallpaper,
                        vertical_fit_policy = "fill",
                        horizontal_fit_policy = "fill",
                        resize = true,
                    }
                }
            }
        }
    }
end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)
end)

return theme

