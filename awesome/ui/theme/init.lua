local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gears = require("gears")
local naughty = require("naughty")
local awful = require("awful")
local gfs = gears.filesystem
local themes_path = gfs.get_themes_dir()

local theme = require("ui.theme.selected_color_scheme")

local icons_path = gfs.get_configuration_dir() .. "/ui/icons/"

theme.icon_font = "Material Symbols Rounded "
theme.font = "Inter"

theme.base_shape = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, dpi(theme.roundness))
end

theme.bar_shape = theme.base_shape

theme.bg_normal      = theme.base
theme.bg_focus       = theme.overlay
theme.bg_urgent      = theme.highlight_med
theme.bg_minimize    = theme.ignored

theme.fg_normal      = theme.white
theme.fg_focus       = theme.white
theme.fg_unfocus     = theme.inactive
theme.fg_urgent      = theme.red
theme.fg_minimize    = theme.highlight_high

if theme.transparency_enabled then
    theme.opaque            = "ff"
    theme.semi_transparent  = "bf"
    theme.transparent       = "5f"
    theme.fully_transparent = "00"
    theme.bg_transparent    = "#00000000"

    theme.opacity_active    = 0.8
    theme.opacity_normal    = 0.7
    theme.opacity_new       = 0.7
    theme.opacity_fullscreen= 1.0
else
    theme.opaque            = "ff"
    theme.semi_transparent  = "ff"
    theme.transparent       = "ff"
    theme.fully_transparent = "ff"
    theme.bg_transparent    = theme.bg_focus

    theme.opacity_active    = 1.0
    theme.opacity_normal    = 1.0
    theme.opacity_new       = 1.0
    theme.opacity_fullscreen= 1.0
end

theme.wibar_fg           = theme.white
theme.wibar_bg           = theme.base
theme.wibar_border_color = theme.accent

theme.useless_gap       = dpi(6)
theme.border_width      = dpi(3)
theme.gap_single_client = true
theme.border_normal     = theme.surface .. "99"
theme.border_focus      = theme.accent
theme.border_marked     = theme.yellow

theme.button_bg_off   = theme.transparency_enabled and theme.inactive .. theme.transparent
                                                   or  theme.highlight_med
theme.button_bg_on    = theme.second_accent

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
theme.taglist_fg_focus = theme.text
theme.taglist_fg_empty = theme.inactive
theme.taglist_fg_occupied = theme.second_accent
theme.taglist_fg_urgent = theme.red
theme.taglist_bg_focus = theme.bg_normal .. theme.semi_transparent

theme.hotkeys_bg = theme.bg_normal .. theme.transparent
theme.hotkeys_border_color = theme.border_focus
theme.hotkeys_modifiers_fg = theme.fg_normal
theme.hotkeys_shape = theme.base_shape

theme.tag_preview_widget_border_radius = dpi(7)
theme.tag_preview_widget_border_width = dpi(2)
theme.tag_preview_widget_border_color = theme.border_focus
theme.tag_preview_widget_bg = theme.bg_normal
theme.tag_preview_widget_margin = dpi(4)
theme.tag_preview_client_border_radius = dpi(7)
theme.tag_preview_client_border_width = dpi(1)
theme.tag_preview_client_border_color = theme.border_normal

theme.titlebar_close_button_normal       = icons_path .. "titlebar/titlebutton.svg"
theme.titlebar_close_button_normal_hover = icons_path .. "titlebar/close.svg"
theme.titlebar_close_button_focus        = icons_path .. "titlebar/close.svg"
theme.titlebar_close_button_focus_hover  = icons_path .. "titlebar/close_hover.svg"

theme.titlebar_maximized_button_normal_inactive      = icons_path .. "titlebar/titlebutton.svg"
theme.titlebar_maximized_button_normal_hover         = icons_path .. "titlebar/maximize.svg"
theme.titlebar_maximized_button_focus_inactive       = icons_path .. "titlebar/maximize.svg"
theme.titlebar_maximized_button_focus_inactive_hover = icons_path .. "titlebar/maximize_hover.svg"

theme.titlebar_minimize_button_normal       = icons_path .. "titlebar/titlebutton.svg"
theme.titlebar_minimize_button_normal_hover = icons_path .. "titlebar/minimize.svg"
theme.titlebar_minimize_button_focus        = icons_path .. "titlebar/minimize.svg"
theme.titlebar_minimize_button_focus_hover  = icons_path .. "titlebar/minimize_hover.svg"

theme.titlebar_floating_button_normal_inactive      = icons_path .. "titlebar/titlebutton.svg"
theme.titlebar_floating_button_normal_hover         = icons_path .. "titlebar/float.svg"
theme.titlebar_floating_button_focus_inactive       = icons_path .. "titlebar/float.svg"
theme.titlebar_floating_button_focus_inactive_hover = icons_path .. "titlebar/float_hover.svg"

theme.prompt_bg = theme.fully_transparent

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
theme.tooltip_bg = theme.bg_normal .. theme.transparent
theme.tooltip_margin = dpi(4)

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]
theme.notification_max_height = dpi(350)
theme.notification_max_width = dpi(350)

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themes_path.."default/submenu.png"
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)

-- You can use your own layout icons like this:
theme.layout_fairh = themes_path.."default/layouts/fairh.png"
theme.layout_fairv = themes_path.."default/layouts/fairv.png"
theme.layout_floating  = themes_path.."default/layouts/floating.png"
theme.layout_magnifier = themes_path.."default/layouts/magnifier.png"
theme.layout_max = themes_path.."default/layouts/max.png"
theme.layout_fullscreen = themes_path.."default/layouts/fullscreen.png"
theme.layout_tilebottom = themes_path.."default/layouts/tilebottom.png"
theme.layout_tileleft   = themes_path.."default/layouts/tileleft.png"
theme.layout_tile = themes_path.."default/layouts/tile.png"
theme.layout_tiletop = themes_path.."default/layouts/tiletop.png"
theme.layout_spiral  = themes_path.."default/layouts/spiral.png"
theme.layout_dwindle = themes_path.."default/layouts/dwindle.png"
theme.layout_cornernw = themes_path.."default/layouts/cornernw.png"
theme.layout_cornerne = themes_path.."default/layouts/cornerne.png"
theme.layout_cornersw = themes_path.."default/layouts/cornersw.png"
theme.layout_cornerse = themes_path.."default/layouts/cornerse.png"

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = "~/.icons/Rose-Pine/index.theme"

theme.wallpaper = "/home/nathan/Pictures/wallpapers/shaded_landscape.png"

local function set_wallpaper(s)
    -- Wallpaper
    if theme.wallpaper then
        -- If wallpaper is a function, call it with the screen
        if type(theme.wallpaper) == "function" then
            theme.wallpaper = theme.wallpaper(s)
        end
        gears.wallpaper.maximized(theme.wallpaper, s, true)
    end
end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)
end)

return theme

