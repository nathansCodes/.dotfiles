local awful          = require("awful")
local wibox          = require("wibox")
local beautiful      = require("beautiful")

local dpi            = beautiful.xresources.apply_dpi
local helpers        = require("helpers")
local button         = require("ui.widget.button")
local menu           = require("ui.widget.menu")

local sep            = wibox.widget.textbox("       ")
sep.forced_height    = dpi(650)
sep.forced_width     = dpi(70)

local capi = { awesome = awesome }

local logo = wibox.widget {
    widget = wibox.container.margin,
    top = dpi(15),
    {
        widget = wibox.widget.textbox,
        font = beautiful.mono_font .. "Bold 20",
        markup = helpers.ui.colorize_text(" ", beautiful.accent)
    }
}

local lock_confirm = menu.button {
    text = "Lock",
    icon = "\u{e897}",
    icon_color = beautiful.blue,
    on_press = function()
        capi.awesome.emit_signal("lockscreen::lock")
        capi.awesome.emit_signal("launcher::close")
    end,
}

local logout_confirm = menu.button {
    text = "Log out",
    icon = "\u{e9ba}",
    icon_color = beautiful.green,
    on_press = function()
        capi.awesome.quit()
    end,
}

local reboot_confirm = menu.button {
    text = "Reboot",
    icon = "\u{f053}",
    icon_color = beautiful.magenta,
    on_press = function()
        awful.spawn("systemctl reboot")
    end
}

local shutdown_confirm = menu.button {
    text = "Shutdown",
    icon = "\u{e8ac}",
    icon_color = beautiful.red,
    on_press = function()
        awful.spawn("systemctl poweroff")
    end
}

local confirm_menu = menu.menu {
    width = dpi(200),
    bg = beautiful.base,
    {
        widget = wibox.container.margin,
        top = dpi(10),
        {
            widget = wibox.widget.textbox,
            font = beautiful.font .. "SemiBold 12",
            valign = "center",
            halign = "center",
            text = "Are you sure?"
        }
    },
    wibox.widget.textbox(),
    menu.button {
        text = "Cancel",
        icon = "\u{e5cd}",
        icon_color = beautiful.text,
    },
}

lock_confirm.menu = confirm_menu
logout_confirm.menu = confirm_menu
reboot_confirm.menu = confirm_menu
shutdown_confirm.menu = confirm_menu
lock_confirm:set_bg(beautiful.base)
logout_confirm:set_bg(beautiful.base)
reboot_confirm:set_bg(beautiful.base)
shutdown_confirm:set_bg(beautiful.base)

capi.awesome.connect_signal("launcher::closed", function() confirm_menu:hide() end)

local buttons_hovered = false

local function make_button(icon, col, menu_btn, height_offset)
    return button {
        height = dpi(50),
        width = dpi(50),
        fg = col,
        hover_bg = col,
        hover_fg = beautiful.base,
        on_mouse_enter = function()
            buttons_hovered = true
            if confirm_menu.visible then
                confirm_menu.widget:set(2, menu_btn)
                local launcher_geo = require("ui.components.launcher"):geometry()
                confirm_menu.x = launcher_geo.x - dpi(210)
                confirm_menu.y = launcher_geo.y + launcher_geo.height - height_offset
            end
        end,
        on_mouse_leave = function() buttons_hovered = false end,
        on_release = function()
            confirm_menu.widget:set(2, menu_btn)
            if not confirm_menu.visible then
                confirm_menu:show()
            end
            local launcher_geo = require("ui.components.launcher"):geometry()
            confirm_menu.x = launcher_geo.x - dpi(210)
            confirm_menu.y = launcher_geo.y + launcher_geo.height - height_offset
        end,
        {
            widget = wibox.widget.textbox,
            text = icon,
            font = beautiful.icon_font .. "SemiBold 22",
            valign = "center",
            halign = "center",
        }
    }
end

local sidebar = wibox.widget {
    widget = wibox.container.background,
    buttons = {awful.button({"Any"}, 1, function()
        if not buttons_hovered then confirm_menu:hide() end
    end)},
    bg = beautiful.base,
    {
        layout = wibox.layout.stack,
        sep,
        {
            layout = wibox.layout.fixed.vertical,
            fill_space = true,
            {
                widget = wibox.container.place,
                logo,
            },
            {
                widget = wibox.container.place,
                valign = "bottom",
                {
                    widget = wibox.container.margin,
                    bottom = dpi(10),
                    {
                        layout = wibox.layout.fixed.vertical,
                        spacing = dpi(10),
                        make_button("\u{e9ba}", beautiful.magenta, logout_confirm, dpi(237)),
                        make_button("\u{e897}", beautiful.blue, lock_confirm, dpi(177)),
                        make_button("\u{f053}", beautiful.orange, reboot_confirm, dpi(114)),
                        make_button("\u{e8ac}", beautiful.red, shutdown_confirm, dpi(114)),
                    }
                },
            },
        },
    },
}

return sidebar
