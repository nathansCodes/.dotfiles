local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

function format_item(widget)
    return wibox.widget {
        {
            {
                layout = wibox.layout.align.vertical,
                expand = 'none',
                spacing = dpi(10),
                id = widget.id,
                nil,
                widget,
                nil
            },
            margins = widget.margins or dpi(10),
            left = widget.left or dpi(10),
            right = widget.right or dpi(10),
            top = widget.top or dpi(10),
            bottom = widget.bottom or dpi(10),
            widget = wibox.container.margin
        },
        forced_height = widget.forced_height or dpi(88),
        border_width  = widget.border_width or dpi(0),
        border_color  = widget.border_color or beautiful.border_normal,
        bg = widget.bg or beautiful.bg_focus .. beautiful.semi_transparent,
        shape = widget.shape or function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 20)
        end,
        widget = wibox.container.background,
        id = widget.id,
    }
end

function format_item_no_fix_height(widget)
    return wibox.widget {
        {
            {
                layout = wibox.layout.align.vertical,
                spacing = widget.spacing or dpi(10),
                expand = 'none',
                nil,
                widget,
                nil
            },
            margins = widget.margins or dpi(10),
            left = widget.left or dpi(10),
            right = widget.right or dpi(10),
            top = widget.top or dpi(10),
            bottom = widget.bottom or dpi(10),
            widget = wibox.container.margin
        },
        forced_height = widget.forced_height or dpi(88),
        border_width  = widget.border_width or dpi(0),
        border_color  = widget.border_color or beautiful.border_normal,
        bg = widget.bg or beautiful.bg_focus .. beautiful.semi_transparent,
        id = widget.id or "bg",
        shape = widget.shape or function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 20)
        end,
        widget = wibox.container.background,
    }
end

