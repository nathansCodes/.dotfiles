local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local notifbox_core = {}

local scroller = require("ui.control_panel.notification_center.scroller")

notifbox_core.empty = wibox.widget {
    widget = wibox.widget.textbox,
    text = "No new notifications",
    font = "Inter Regular 14",
    align = "center",
    valign = "center",
    forced_height = dpi(500),
}
notifbox_core.remove_notifbox_empty = true

notifbox_core.layout = wibox.widget {
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(6),
    notifbox_core.empty,
}

function notifbox_core.reset_notifbox_layout()
	notifbox_core.layout:reset()
	notifbox_core.layout:insert(1, notifbox_core.empty)
	notifbox_core.remove_notifbox_empty = true
end

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
    border_width = 1,
    border_color = beautiful.bg_minimize .. beautiful.transparent,
    shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 20)
    end,
    {
        layout = wibox.layout.fixed.vertical,
        fill_space = true,
        spacing = 8,
        {
            widget = wibox.container.margin,
            top = 10,
            left = 8,
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
    local w = mouse.current_wibox
    if w then
        old_wibox = w
        clear_all:get_children_by_id("text").valign = "center"
        w.cursor = 'hand1'
    end
    clear_all.fg = beautiful.fg_focus
end)

clear_all:connect_signal('mouse::leave', function()
    if old_wibox then
        old_wibox.cursor = "left_ptr"
        clear_all:get_children_by_id("text").valign = "bottom"
       old_wibox = nil
    end
    clear_all.fg = beautiful.fg_unfocus
end)


clear_all:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        if not notifbox_core.remove_notifbox_empty then
            naughty.destroy_all_notifications(nil, 1)
            notifbox_core.layout:reset(notifbox_core.layout)
        end
    end
end)

naughty.connect_signal("request::display", function(n)
    if #notifbox_core.layout.children == 1 and notifbox_core.remove_notifbox_empty then
        notifbox_core.layout:reset(notifbox_core.layout)
        notifbox_core.remove_notifbox_empty = false
    end
    local builder = require("ui.control_panel.notification_center.notifbox_builder")
    notifbox_core.layout:insert(1, builder.build_notifbox(n, n.icon, n.title, n.message, n.app_name))
end)

scroller(notifbox_core.layout)

return notifbox_core
