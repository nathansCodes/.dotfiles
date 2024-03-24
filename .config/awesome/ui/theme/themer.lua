local xresources = require("beautiful.xresources")

local gears = require("gears")
local awful = require("awful")
local gfs = gears.filesystem
local awm_conf_dir = gfs.get_configuration_dir()

local settings = require("config.user_settings")

local themer = {}

function themer.apply()
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


    local nvim_packman = settings.theme.nvim.package_manager or ""
    local nvim_theme_name = theme.nvim_theme_name or theme_name:gsub(" ", "-")
            .. (theme_variant ~= "" and "-"..theme_variant)

    local firefox_install = settings.theme.firefox.install
    local firefox_profile = settings.theme.firefox.profile
    local discord_install = settings.theme.discord.install
    local discord_mod = settings.theme.discord.client_mod

    -- create commands for applying the theme
    -- or leave empty if the user doesn't want it
    local apply_discord = settings.theme.discord.enabled
        and ( "discord '" .. discord_install .. "' '" .. discord_mod .. "'" ) or ""
    local apply_xres_term = settings.theme.xresources_enabled and "term" or ""
    local apply_alacritty = settings.theme.alacritty.enabled and
        ( "alacritty '" .. theme_name:gsub(" ", "_")
        .. (theme_variant ~= "" and "_"..theme_variant) .. "'" ) or ""
    local apply_gtk = settings.theme.gtk.enabled and "gtk" or ""
    local apply_nvim = settings.theme.nvim.enabled and (
        "nvim " .. "'" .. nvim_theme_name .. "' '" .. nvim_packman .. "'" ) or ""
    local apply_firefox = settings.theme.firefox.enabled and (
        "userchrome '" .. firefox_install .. "' '" .. firefox_profile .. "'\n" ..
        "usercontent '" .. firefox_install .. "' '" .. firefox_profile .. "'" ) or ""

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


        ]=] .. apply_discord   .. "\n" .. [=[
        ]=] .. apply_xres_term .. "\n" .. [=[
        ]=] .. apply_alacritty .. "\n" .. [=[
        ]=] .. apply_gtk       .. "\n" .. [=[
        ]=] .. apply_firefox   .. "\n" .. [=[
        ]=] .. apply_nvim      .. "\n" .. [=[
    ]=]

    -- apply theme
    awful.spawn.with_shell(apply_script)

    theme.path = theme_path

    return theme
end

function themer.revert()
    local firefox_install = settings.theme.firefox.install
    local firefox_profile = settings.theme.firefox.profile
    local discord_install = settings.theme.discord.install
    local discord_mod = settings.theme.discord.client_mod

    -- create commands for reverting the theme
    -- or leave empty if the user doesn't want it
    local discord = settings.theme.discord.enabled
        and ( "discord '" .. discord_install .. "' '" .. discord_mod .. "'" ) or ""
    local gtk = settings.theme.gtk.enabled and "gtk" or ""
    local firefox = settings.theme.firefox.enabled and (
        "userchrome '" .. firefox_install .. "' '" .. firefox_profile .. "'\n" ..
        "usercontent '" .. firefox_install .. "' '" .. firefox_profile .. "'" ) or ""
    local alacritty = settings.theme.alacritty.enabled and "alacritty" or ""

    local unapply_script = [=[
        source $HOME/.config/awesome/scripts/revert_theme.sh

        ]=] .. gtk       .. "\n" .. [=[
        ]=] .. firefox   .. "\n" .. [=[
        ]=] .. discord   .. "\n" .. [=[
        ]=] .. alacritty .. "\n" .. [=[
    ]=]

    -- unapply theme
    awful.spawn.with_shell(unapply_script)
end

return themer
