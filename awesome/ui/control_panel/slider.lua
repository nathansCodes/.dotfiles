local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

return function(args, on_value_changed)
    local slider = wibox.widget {
        id 					= "slider",
        value               = args.value               or 0,
        bar_shape           = args.bar_shape           or gears.shape.rounded_bar,
        bar_height          = args.bar_height          or dpi(8),
        bar_color           = args.bar_color           or beautiful.highlight_med,
        bar_active_color	= args.bar_active_color    or beautiful.secondary_accent,
        bar_border_width    = args.bar_border_width    or 0,
        bar_border_color    = args.bar_border_color    or beautiful.fg_normal .. beautiful.transparent,
        handle_color        = args.handle_color        or beautiful.secondary_accent,
        handle_shape        = args.handle_shape        or gears.shape.circle,
        handle_width        = args.handle_width        or dpi(16),
        handle_height       = args.handle_height       or dpi(16),
        handle_border_color = args.handle_border_color or beautiful.bg_focus,
        handle_border_width = args.handle_border_width or dpi(2),
        forced_height       = args.forced_height,
        forced_width        = args.forced_width,
        widget = wibox.widget.slider,
    }

    slider:connect_signal("property::value", function() on_value_changed(slider:get_value()) end)

    local widget = wibox.widget {
        expand = "none",
        layout = wibox.layout.align.vertical,
        margins = dpi(6),
        nil,
        slider,
        nil,
    }

    function widget:set_value(val)
        slider.value = val
    end

    return widget
end

