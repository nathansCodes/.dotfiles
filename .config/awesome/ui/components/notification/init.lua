local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local gfs = gears.filesystem
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local notifbox_builder = require("ui.components.notification.notifbox_builder")
local helpers = require("helpers")

naughty.connect_signal("request::display", function(n)
    local current_screen = awful.screen.preferred()
    --if _G.dont_disturb or current_screen.right_panel_visible then return end

    local bar = current_screen.bar

    -- create screen's notifbox table if it doesn't exist
    if not current_screen.notifboxes then
        current_screen.notifboxes = {}
    end

    local notifboxes = current_screen.notifboxes

    local i = #notifboxes + 1

    local notifbox = awful.popup {
        minimum_width  = dpi(400),
        minimum_height = dpi(150),
        maximum_width  = dpi(400),
        maximum_height = dpi(450),
        type   = "notification",
        screen = current_screen,
        ontop  = true,

        preferred_positions = { "bottom", "left", "top" },
        preferred_anchors   = "middle",
        offset              = { y = dpi(20) },

        shape = helpers.ui.rrect(10),
        bg    = beautiful.base,
        fg    = n.urgency == "critical" and beautiful.error or beautiful.text,

        widget = notifbox_builder.build_notifbox(n)
    }

    function notifbox:move_all_remaining(w)
        self:move_next_to(w)
        if self.next ~= nil then
            self.next:move_all_remaining(self)
        end
    end

    if #notifboxes ~= 0 then
        notifbox.previous = notifboxes[#notifboxes]
        notifbox.previous.next = notifbox
    end

    function notifbox.move_up(new_index)
        -- insert at new position
        table.insert(notifboxes, new_index, notifbox)
        -- remove at old position
        table.remove(notifboxes, i)

        notifbox:move_next_to(notifbox.previous or bar)

        -- update local index var
        i = new_index

        -- move up next notifbox
        if notifbox.next ~= nil then
            notifbox.next.move_up(i + 1)
        end
    end

    function notifbox.destroy()
        table.remove(notifboxes, i)
        if notifbox.previous ~= nil then
            notifbox.previous.next = notifbox.next
        end
        if notifbox.next ~= nil then
            notifbox.next.previous = notifbox.previous
            notifbox.next.move_up(i)
        end

        notifbox.visible = false
        notifbox = nil

        collectgarbage("collect")
    end

    notifbox.widget:connect_signal("expand", function()
        if notifbox ~= nil and notifbox.next ~= nil then
            notifbox.next:move_all_remaining(notifbox)
        end
    end)
    notifbox.widget:connect_signal("contract", function()
        if notifbox ~= nil and notifbox.next ~= nil then
            notifbox.next:move_all_remaining(notifbox)
        end
    end)

    notifbox:connect_signal("mouse::enter", function()
        -- ridiculously big number since setting it to -1 doesn't work
        n.timeout = 758938
    end)

    if #notifboxes == 0 then
        notifbox:move_next_to(bar)
    else
        notifbox:move_next_to(notifbox.previous)
    end

    n:connect_signal("destroyed", notifbox.destroy)

    table.insert(notifboxes, notifbox)
end)

