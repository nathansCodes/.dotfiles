local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local notifbox_core = {}

local scroller = require("ui.widgets.scroller")

notifbox_core.empty = wibox.widget {
    widget = wibox.widget.textbox,
    text = "No new notifications",
    font = "Inter Regular 14",
    align = "center",
    valign = "center",
    forced_height = dpi(500),
}

notifbox_core.layout = scroller {
    orientation = "vertical",
    spacing = dpi(6),
    empty_widget = notifbox_core.empty,
}

local title = wibox.widget {
    widget = wibox.widget.textbox,
    font = "Inter Bold 16",
    valign = "bottom",
    text = "Notification Center",
}

local clear_all = wibox.widget {
    widget = wibox.container.background,
    fg = beautiful.fg_unfocus,
    {
        widget = wibox.container.margin,
        top = 8,
        right = 16,
        {
            id = "text",
            widget = wibox.widget.textbox,
            font = "Inter Regular 13",
            text = "clear all",
            valgin = "center",
        },
    }
}

notifbox_core.notif_center = wibox.widget {
    widget = wibox.container.background,
    bg = beautiful.bg_focus .. beautiful.transparent,
    shape = beautiful.base_shape,
    {
        layout = wibox.layout.fixed.vertical,
        fill_space = true,
        spacing = dpi(8),
        {
            widget = wibox.container.margin,
            top = dpi(10),
            left = dpi(8),
            {
                layout = wibox.layout.align.horizontal,
                expand = "inside",
                title,
                nil,
                clear_all,
            }
        },
        notifbox_core.layout,
    },
}

local old_wibox

clear_all:connect_signal('mouse::enter', function()
    if notifbox_core.layout:num_children() ~= 0 then
        local w = mouse.current_wibox
        if w then
            old_wibox = w
            clear_all:get_children_by_id("text")[1].valign = "center"
            w.cursor = 'hand1'
        end
        clear_all.fg = beautiful.fg_focus
    end
end)

clear_all:connect_signal('mouse::leave', function()
    if old_wibox then
        old_wibox.cursor = "left_ptr"
        clear_all:get_children_by_id("text")[1].valign = "bottom"
       old_wibox = nil
    end
    clear_all.fg = beautiful.fg_unfocus
end)


clear_all:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        naughty.destroy_all_notifications(nil, 1)
        notifbox_core.layout:reset()
    end
end)

naughty.connect_signal("request::display", function(n)
    local builder = require("ui.control_panel.notification_center.notifbox_builder")
    notifbox_core.layout:insert(1, builder.build_notifbox(n, n.icon, n.title, n.message, n.app_name))
end)

return notifbox_core
