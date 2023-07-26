local filesystem = require("gears.filesystem")
local config_dir = filesystem.get_configuration_dir()
local utils_dir = config_dir .. "utilities/"

return {
	--- Default Applications
	default = {
		--- Default terminal emulator
		terminal = "alacritty",
		--- Default music client
		music_player = "alacritty -e --class music ncmpcpp",
		--- Default text editor
		text_editor = "alacritty -e nvim",
		--- Default code editor
		code_editor = "alacritty -e nvim",
		--- Default web browser
		web_browser = "flatpak run org.mozilla.firefox",
		--- Default file manager
		file_manager = "pcmanfm",
		--- Default network manager
		network_manager = "nm-connection-editor",
		--- Default bluetooth manager
		bluetooth_manager = "blueman-manager",
		--- Default power manager
		power_manager = "xfce4-power-manager",
		--- Default rofi global menu
		app_launcher = "/home/nathan/.config/rofi/scripts/launcher_t1"
	},

	--- List of binaries/shell scripts that will execute for a certain task
	utils = {
		--- Fullscreen screenshot
		full_screenshot = utils_dir .. "screensht full",
		--- Area screenshot
		area_screenshot = utils_dir .. "screensht area",
		--- Color Picker
		color_picker = utils_dir .. "xcolor-pick",
	},
}
