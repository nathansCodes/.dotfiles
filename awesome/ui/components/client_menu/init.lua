local awful = require("awful")
local beautiful = require("beautiful")

local menu = require("ui.widget.menu")

return function(c)
    local tags_menu = menu { }

    -- add button for each tag
    for _, tag in ipairs(awful.screen.focused().tags) do
        tags_menu:add(menu.button {
            icon = tag.icon,
            icon_color = beautiful.third_accent,
            text = tag.name,
            secondary_text = "Super+Shift+"..tag.index,
            on_press = function()
                c:move_to_tag(tag)
            end,
        })
    end

    return menu {
        menu.button {
            icon = "\u{e5cd}",
            icon_color = beautiful.error,
            text = "Close",
            secondary_text = "Super+Q",
            on_press = function()
                c:kill()
            end
        },
        menu.button {
            icon = "\u{e069}",
            icon_color = beautiful.warn2,
            text = "Maximize",
            secondary_text = "Super+M",
            on_press = function(_, text_widget)
                c.maximized = not c.maximized
                if c.maximized then
                    text_widget:set_text("Unmaximize")
                else
                    text_widget:set_text("Maximize")
                end
            end
        },
        menu.button {
            icon = "\u{e931}",
            icon_color = beautiful.success,
            text = "Minimize",
            on_press = function()
                c.minimized = not c.minimized
            end
        },
        menu.separator(),
        menu.button {
            icon = "\u{e5d0}",
            icon_color = beautiful.accent,
            text = "Fullscreen",
            secondary_text = "Super+Shift+F",
            on_press = function()
                c.fullscreen = not c.fullscreen
            end
        },
        menu.button {
            icon = "\u{e6fa}",
            icon_color = beautiful.accent,
            text = c.floating and "Tile" or "Float",
            secondary_text = "Super+F",
            on_press = function(_, text_widget)
                c.floating = not c.floating
                if c.floating then
                    text_widget:set_text("Tile")
                else
                    text_widget:set_text("Float")
                end
            end
        },
        menu.sub_menu_button {
            icon = "\u{f742}",
            icon_color = beautiful.accent,
            text = "Move to tag",
            --secondary_text = "Super+Shift+#",
            sub_menu = tags_menu
        }
    }
end
