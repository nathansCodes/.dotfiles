--------------------------
-- Rose Pine Moon theme --
--------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gears = require("gears")
local gfs = gears.filesystem
local themes_path = gfs.get_themes_dir()

local theme = {}

theme.base           = "#232136"
theme.surface        = "#2a273f"
theme.overlay        = "#393552"
theme.muted          = "#6e6a86"
theme.subtle         = "#908caa"
theme.text           = "#e0def4"
theme.love           = "#eb6f92"
theme.gold           = "#f6c177"
theme.rose           = "#ea9a97"
theme.pine           = "#3e8fb0"
theme.foam           = "#9ccfd8"
theme.iris           = "#c4a7e7"
theme.highlight_low  = "#2a283e"
theme.highlight_med  = "#44415a"
theme.highlight_high = "#56526e"

theme.opaque            = "ff"
theme.semi_transparent  = "bf"
theme.transparent       = "55"
theme.fully_transparent = "00"
theme.bg_transparent    = "#00000000"

theme.opacity_active    = 0.8
theme.opacity_normal    = 0.6
theme.opacity_new       = 0.6
theme.opacity_fullscreen= 1.0

theme.font = "CaskaydiaCoveNerdFontMono"

theme.bg_normal      = theme.base
theme.bg_focus       = theme.overlay
theme.bg_urgent      = theme.highlight_med
theme.bg_minimize    = theme.muted

theme.fg_normal      = theme.text
theme.fg_focus       = theme.text
theme.fg_unfocus     = theme.subtle
theme.fg_urgent      = theme.love
theme.fg_minimize    = theme.highlight_high

theme.wibar_fg       = theme.text
theme.wibar_bg       = theme.base .. theme.semi_transparent

theme.useless_gap       = dpi(6)
theme.border_width      = dpi(4)
theme.gap_single_client = true
theme.border_normal     = theme.base
theme.border_focus      = theme.rose
theme.border_marked     = theme.gold
theme.broder_primary    = theme.border_focus
theme.border_secondary  = theme.pine

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
theme.taglist_bg_focus = theme.bg_normal .. theme.opaque
theme.taglist_fg_focus = theme.bg_normal
theme.taglist_shape_border_width_focus = 2
theme.taglist_shape_border_color = theme.fully_transparent
theme.taglist_shape_border_color_focus = theme.pine .. theme.opaque
theme.taglist_shape_border_width_urgent = 2
theme.taglist_shape_border_color = theme.fully_transparent
theme.taglist_shape_border_color_urgent = theme.love .. theme.opaque

theme.prompt_bg = theme.fully_transparent

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]
theme.notification_font = theme.font
theme.notification_border_width = 4
theme.notification_fg = theme.fg_focus
theme.notification_bg = theme.wibar_bg
theme.notification_border_color = theme.pine
theme.notification_border_width = 2
theme.notification_shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, 20)
end

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themes_path.."default/submenu.png"
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)

theme.wallpaper = themes_path.."default/background.png"

-- You can use your own layout icons like this:
theme.layout_fairh = themes_path.."default/layouts/fairhw.png"
theme.layout_fairv = themes_path.."default/layouts/fairvw.png"
theme.layout_floating  = themes_path.."default/layouts/floatingw.png"
theme.layout_magnifier = themes_path.."default/layouts/magnifierw.png"
theme.layout_max = themes_path.."default/layouts/maxw.png"
theme.layout_fullscreen = themes_path.."default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path.."default/layouts/tilebottomw.png"
theme.layout_tileleft   = themes_path.."default/layouts/tileleftw.png"
theme.layout_tile = themes_path.."default/layouts/tilew.png"
theme.layout_tiletop = themes_path.."default/layouts/tiletopw.png"
theme.layout_spiral  = themes_path.."default/layouts/spiralw.png"
theme.layout_dwindle = themes_path.."default/layouts/dwindlew.png"
theme.layout_cornernw = themes_path.."default/layouts/cornernww.png"
theme.layout_cornerne = themes_path.."default/layouts/cornernew.png"
theme.layout_cornersw = themes_path.."default/layouts/cornersww.png"
theme.layout_cornerse = themes_path.."default/layouts/cornersew.png"

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = "~/.icons/Rose-Pine/index.theme"

return theme

