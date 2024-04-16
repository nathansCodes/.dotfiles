local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local settings = require("config.user_settings")
local button = require("ui.widget.button")

local icon_path = beautiful.icon_theme_path

local function create_button(icon, launch_command)
	return button {
		height = dpi(50),
		width = dpi(50),
		bg = beautiful.base,
		shape = gears.shape.rounded_rect,
        on_press = function(_, _, _, _, b)
            if b == 1 then
                awful.spawn.with_shell(launch_command)
            end
        end,
		widget = wibox.widget {
            widget = wibox.container.margin,
            margins = dpi(10),
            {
                widget = wibox.widget.imagebox,
                image = icon,
                resize = false,
                halign = "center",
                valign = "center",
                opacity = 1,
            }
		},
	}
end

local function get_icon(name)
    return icon_path .. "/32x32/apps/" .. name
end

local browser = settings.program.default_apps.browser
local file_manager = settings.program.default_apps.file_manager
local term = settings.program.default_apps.terminal

local discord_cmd = settings.theme.discord.install == "flatpak"
    and "flatpak run org.mozilla.firefox" or "discord"

local apps = {
	firefox = create_button(browser:get_icon(), browser.command),
    file_manager = create_button(file_manager:get_icon(), file_manager.command),
	term = create_button(term:get_icon(), term.command),
	libreoffice = create_button(get_icon("libreoffice.svg"), "libreoffice"),
    steam = create_button(get_icon("steam.svg"), "steam"),
	discord = create_button(get_icon("discord.svg"), discord_cmd),
	godot = create_button(get_icon("godot.svg"), "godot"),
}

return apps
