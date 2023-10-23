local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local button = require("ui.widgets.button")

_G.dont_disturb = false

return function()
    local icon = wibox.widget {
        widget = wibox.widget.textbox,
        text = '\u{e7f7}',
        font = beautiful.icon_font .. "30",
        halign = "center",
    }

    local widget = button {
        id = "icon_bg",
        widget = wibox.container.background,
        shape = gears.shape.circle,
        bg = beautiful.button_bg_off,
        left = true,
        bottom = true,
        callback = function(self, _, _, b)
            if b ~= 1 then return end
            if _G.dont_disturb == true then
                _G.dont_disturb = false
                icon:set_markup_silently("\u{e7f7}")
                self.bg = beautiful.button_bg_off
                self.fg = beautiful.fg_normal
            else
                _G.dont_disturb = true
                icon:set_markup_silently("\u{e7f6}")
                self.bg = beautiful.button_bg_on
                self.fg = beautiful.bg_focus
            end
        end,
        icon,
    }

    return widget
end
