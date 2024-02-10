local awful          = require("awful")
local wibox          = require("wibox")
local beautiful      = require("beautiful")

local dpi            = beautiful.xresources.apply_dpi
local helpers        = require("helpers")
local button         = require("ui.widget.button")

local sep            = wibox.widget.textbox("       ")
sep.forced_height    = dpi(650)
sep.forced_width     = dpi(70)

local logo           = wibox.widget {
    widget = wibox.container.margin,
    top = dpi(15),
    {
        widget = wibox.widget.textbox,
        font = beautiful.mono_font .. "Bold 20",
        markup = helpers.ui.colorize_text(" ", beautiful.accent)
    }
}

local create_buttons = function(icon, fg, size)
    local text = {
        widget = wibox.widget.textbox,
        font = beautiful.icon_font .. size,
        markup = helpers.ui.colorize_text(icon, fg)
    }
    text.valign = "center"
    text.halign = "center"

    local text_icon = wibox.widget {
        widget = wibox.container.margin,
        margins = dpi(10),
        {
            text,
            widget = wibox.container.place
        },
    }
    text_icon.forced_height = dpi(50)
    text_icon.forced_width = dpi(50)

    local icon_bg = button {
        shape = helpers.ui.rrect(10),
        {
            widget = wibox.container.place,
            text_icon,
        },
    }

    return wibox.widget { widget = wibox.container.margin, bottom = dpi(10), icon_bg }
end

local sidebar = wibox.widget {
    {
        {
            {
                logo,
                widget = wibox.container.place
            },
            nil,
            {
                {
                    create_buttons("\u{e9ba}", beautiful.green, 19),
                    create_buttons("\u{f053}", beautiful.magenta, 22),
                    create_buttons("\u{e8ac}", beautiful.red, 22),
                    layout = wibox.layout.fixed.vertical
                },
                widget = wibox.container.place
            },
            layout = wibox.layout.align.vertical
        },
        sep,
        layout = wibox.layout.stack
    },
    widget = wibox.container.background,
    bg = beautiful.base,
}

return sidebar
