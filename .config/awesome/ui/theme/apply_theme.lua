local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gears = require("gears")
local naughty = require("naughty")
local awful = require("awful")
local gfs = gears.filesystem
local themes_dir = gfs.get_themes_dir()
local awm_conf_dir = gfs.get_configuration_dir()
local dotfiles_dir = awm_conf_dir .. "/../"

local settings = require("config.user_settings")

-- load theme based on user preference
local theme_name = string.lower(settings.theme.theme or "catppuccin")
local theme_variant = string.lower(settings.theme.variant or "mocha")
local theme_path = awm_conf_dir.."ui/theme/themes/"..theme_name

-- set theme to catppuccin if it doesn't exist
if not gfs.is_dir(theme_path) then
    theme_name = "catppuccin"
    theme_path = awm_conf_dir.."ui/theme/themes/"..theme_name
end

theme_path = theme_path.."/"..theme_variant.."/"

-- set variant to default if it doesn't exist
if not gfs.is_dir(theme_path) or not theme_variant then
    theme_variant = require("ui.theme.themes."..theme_name)
    theme_path = awm_conf_dir.."ui/theme/themes/"..theme_name.."/"..theme_variant.."/"
end

-- handle case of only one variant
if type(theme_variant) == "table" then
    theme_variant = "init"
    theme_path = awm_conf_dir.."ui/theme/themes/"..theme_name.."/"
end

local theme = require("ui.theme.themes." .. theme_name .. "." .. theme_variant)

theme.theme_name = theme_name
theme.theme_variant = theme_variant == "init" and nil or theme_variant

-- apply rofi theme
local rofi_theme = theme_name:gsub(" ", "_") .. "_" .. theme_variant:gsub(" ", "_")
local apply_rofi = 'echo \'@import \"~/.config/rofi/colors/'
    .. rofi_theme .. '.rasi\"\' > ~/.config/rofi/resources/colors.rasi'
awful.spawn.with_shell(apply_rofi)

-- check for icon theme in `/usr/share/icons`, `~/.icons/`, and `~/.local/share/icons/`
local function icon_theme_exists(icon_theme)
    if gfs.is_dir("/usr/share/icons/"..icon_theme) then
        return true, "/usr/share/icons/"..icon_theme
    end
    if gfs.is_dir("~/.icons/"..icon_theme) then
        return true, "~/.icons/"..icon_theme
    end
    if gfs.is_dir("~/.local/share/icons/"..icon_theme) then
        return true, "~/.local/share/icons/"..icon_theme
    end
    return false, nil
end

theme.icon_theme = settings.theme.icon_theme or theme.icon_theme or "Papirus"

local icons_exist, icons_dir = icon_theme_exists(theme.icon_theme)

if not icons_exist then
    theme.icon_theme = "Papirus"
    theme.icon_theme_path = "/usr/share/icons/Papirus"
else
    theme.icon_theme_path = icons_dir
end


local nvim_theme_name = theme_name == "biscuit" and "biscuit"
    or theme_name:gsub(" ", "-") .. (theme_variant ~= "" and "-"..theme_variant)

local firefox_install = settings.theme.firefox_install
local firefox_profile = settings.theme.firefox_profile
local discord_install = settings.theme.discord_install

local apply_script = [=[
    #!/usr/bin/env bash

    # Colors
    BASE="]=] .. theme.base .. [=["
    SURFACE="]=] .. theme.surface .. [=["
    OVERLAY="]=] .. theme.overlay .. [=["
    INACTIVE="]=] .. theme.highlight_high .. [=["
    FG="]=] .. theme.text .. [=["
    HL_LOW="]=] .. theme.highlight_low .. [=["
    HL_MED="]=] .. theme.highlight_med .. [=["
    HL_HIGH="]=] .. theme.highlight_high .. [=["
    ACCENT="]=] .. theme.accent .. [=["
    ACCENT2="]=] .. theme.third_accent .. [=["
    ACCENT3="]=] .. theme.second_accent .. [=["
    ERROR="]=] .. theme.red .. [=["
    WARN="]=] .. theme.yellow .. [=["
    SUCCESS="]=] .. theme.green .. [=["
    CLOSE="]=] .. theme.error .. [=["
    MAXIMIZE="]=] .. theme.warn2 .. [=["
    MINIMIZE="]=] .. theme.success .. [=["

    BLACK="]=] .. theme.base .. [=["
    WHITE="]=] .. theme.text .. [=["
    RED="]=] .. theme.red .. [=["
    GREEN="]=] .. theme.green .. [=["
    YELLOW="]=] .. theme.yellow .. [=["
    BLUE="]=] .. theme.blue .. [=["
    MAGENTA="]=] .. theme.magenta .. [=["
    CYAN="]=] .. theme.cyan .. [=["
    ICON_THEME="]=] .. theme.icon_theme .. [=["


    source $HOME/.config/awesome/scripts/apply_theme.sh


    if [[ ! "$NO_DISCORD" = "true" ]]; then
        discord "]=] .. discord_install .. [=["
    fi
    if [[ ! "$NO_TERM" ]]; then
        term
    fi
    if [[ ! "$NO_ALACRITTY" ]]; then
        alacritty "]=] .. theme_name:gsub(" ", "_") ..
            (theme_variant ~= "" and "_"..theme_variant) .. [=["
    fi
    if [[ ! "$NO_GTK" = "true" ]]; then
        gtk
    fi
    if [[ ! "$NO_NVIM" = "true" ]]; then
        nvim "]=] .. nvim_theme_name .. [=["
    fi
    if [[ ! "$NO_FF" = "true" ]]; then
        userchrome "]=] .. firefox_install .. '" "' .. firefox_profile .. [=["
        usercontent "]=] .. firefox_install .. '" "' .. firefox_profile .. [=["
    fi
]=]

-- apply theme
awful.spawn.with_shell(apply_script)

theme.path = theme_path

return theme
