local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local apps = require("config.apps")
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
                image = icon_path .. "/32x32/apps/" ..  icon,
                resize = false,
                halign = "center",
                valign = "center",
                opacity = 1,
            }
		},
	}
end

local apps = {
	firefox = create_button("firefox.svg", "firefox"),
    file_manager = create_button("nautilus.svg", "nautilus"),
	term = create_button("Alacritty.svg", apps.terminal),
	libreoffice = create_button("libreoffice.svg", "libreoffice"),
    steam = create_button("steam.svg", "steam"),
	discord = create_button("discord.svg", "flatpak run com.discordapp.Discord"),
	--gimp = create_button("gimp.svg", "gimp"),
	godot = create_button("godot.svg", "godot"),
	--keepassxc = create_button("keepassxc.svg", "keepassxc"),
}

return apps
