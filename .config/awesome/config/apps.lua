local gears = require("gears")
local user = require("config.user_settings")

--- Default Applications
local default = {
    --- Default terminal emulator
    terminal = "alacritty",
    --- Default music client
    music_player = "spotube",
    --- Default text editor
    text_editor = "alacritty -e nvim",
    --- Default code editor
    code_editor = "alacritty -e nvim",
    --- Default web browser
    web_browser = user.theme.firefox_install == "flatpak"
        and "flatpak run org.mozilla.firefox" or "firefox",
    --- Default file manager
    file_manager = "nautilus",
    --- Default network manager
    network_manager = "nm-connection-editor",
    --- Default bluetooth manager
    bluetooth_manager = "blueman-manager",
}

return gears.table.crush(default, user.program.default_apps or {}, true)
