local awful = require("awful")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")

local menu = require("ui.widget.menu")
local settings = require("config.user_settings")

local capi = { awesome = awesome, mouse = mouse }

local conf_dir = gfs.get_configuration_dir()

local main_menu = menu {
    menu.button {
        icon = "\u{e8b6}",
        icon_color = beautiful.accent,
        text = "Applications",
        secondary_text = "Super+R",
        on_press = function()
            capi.awesome.emit_signal("launcher::open")
        end
    },
    menu.button {
        icon = "\u{e051}",
        icon_color = beautiful.accent,
        text = "Web Browser",
        secondary_text = "Super+B",
        on_press = function()
            awful.spawn(settings.program.default_apps.browser.command)
        end
    },
    menu.button {
        icon = "\u{eb8e}",
        icon_color = beautiful.accent,
        text = "Terminal",
        secondary_text = "Super+T",
        on_press = function()
            awful.spawn(settings.program.default_apps.terminal.command)
        end
    },
    menu.button {
        icon = "\u{e2c8}",
        icon_color = beautiful.accent,
        text = "File Manager",
        secondary_text = "Super+E",
        on_press = function()
            awful.spawn(settings.program.default_apps.file_manager.command)
        end
    },
    menu.button {
        icon = "\u{f88c}",
        icon_color = beautiful.accent,
        text = "Text Editor",
        on_press = function()
            awful.spawn(settings.program.default_apps.text_editor.command)
        end
    },
    menu.button {
        icon = "\u{e86f}",
        icon_color = beautiful.accent,
        text = "Code Editor",
        on_press = function()
            awful.spawn(settings.program.default_apps.code_editor.command)
        end
    },
    menu.button {
        icon = "\u{ea28}",
        icon_color = beautiful.accent,
        text = "Steam",
        on_press = function()
            awful.spawn("steam")
        end
    },
    menu.separator(),
    menu.sub_menu_button {
        image = conf_dir .. "ui/icons/awm_a.svg",
        image_color = beautiful.third_accent,
        text = "AwesomeWM",
        sub_menu = menu {
            menu.button {
                icon = "\u{f053}",
                icon_color = beautiful.orange,
                text = "Restart",
                secondary_text = "Super+Ctrl+R",
                on_press = function()
                    capi.awesome.restart()
                end
            },
            menu.button {
                icon = "\u{e9ba}",
                icon_color = beautiful.magenta,
                text = "Quit",
                secondary_text = "Super+Shift+Q",
                on_press = function()
                    capi.awesome.quit()
                end
            },
            menu.separator(),
            menu.button {
                icon = "\u{e745}",
                icon_color = beautiful.third_accent,
                text = "Edit config",
                on_press = function()
                    awful.spawn(settings.program.default_apps.code_editor.command .. " '" .. conf_dir .. "'")
                end
            },
            menu.button {
                icon = "\u{e88e}",
                icon_color = beautiful.third_accent,
                text = "Awesome Git Docs",
                on_press = function()
                    awful.spawn("xdg-open https://awesomewm.org/apidoc")
                end
            },
            menu.button {
                icon = "\u{e88e}",
                icon_color = beautiful.third_accent,
                text = "Awesome 4.3 Docs",
                on_press = function()
                    awful.spawn("xdg-open https://awesomewm.org/doc/api")
                end
            },
        }
    },
    menu.sub_menu_button {
        icon = "\u{e8ac}",
        icon_color = beautiful.third_accent,
        text = "Power",
        secondary_text = "Super+V",
        sub_menu = menu {
            menu.button {
                icon = "\u{e8ac}",
                icon_color = beautiful.red,
                text = "Shutdown",
                secondary_text = "S",
                on_press = function()
                    awful.spawn("systemctl poweroff")
                end
            },
            menu.button {
                icon = "\u{f053}",
                icon_color = beautiful.orange,
                text = "Reboot",
                secondary_text = "R",
                on_press = function()
                    awful.spawn("systemctl reboot")
                end
            },
            menu.button {
                icon = "\u{e897}",
                icon_color = beautiful.blue,
                text = "Lock",
                secondary_text = "K",
                on_press = function()
                    capi.awesome.emit_signal("lockscreen::lock")
                end
            },
            menu.button {
                icon = "\u{e9ba}",
                icon_color = beautiful.magenta,
                text = "Logout",
                secondary_text = "L",
                on_press = function()
                    capi.awesome.quit()
                end
            },
        },
    },
}

capi.awesome.connect_signal("main_menu::show", function(args)
    main_menu:show {
        wibox = args.wibox,
        widget = args.widget,
        coords = { x = args.x, y = args.y },
    }
end)

return main_menu
