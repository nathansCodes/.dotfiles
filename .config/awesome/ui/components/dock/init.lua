local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local intersects = gears.geometry.rectangle.area_intersect_area

local rubato = require("modules.rubato")

local helpers = require("helpers")

local tasklist = require("ui.components.dock.widget.tasklist")
local button = require("ui.widget.button")
local launcher = require("ui.components.launcher")

local capi = { awesome = awesome, client = client, tag = tag, mouse = mouse, }

local client_signal = capi.client.connect_signal
local tag_signal = capi.tag.connect_signal
local awesome_signal = capi.awesome.connect_signal


local launcher_icon = button {
    shape = helpers.ui.rrect(14),
    width = dpi(50),
    height = dpi(50),
    widget = wibox.widget {
        widget = wibox.widget.textbox,
        valign = "center",
        halign = "center",
        font = beautiful.icon_font .. "32",
        text = "\u{e5c3}",
    },
    on_release = function(_, _, _, _, b)
        if b ~= 1 then return end
        launcher:toggle()
    end
}


return function(s)

    -- used for the input shape,
    -- to prevent captured clicks outside where the dock is, when hidden
    local input_shape_height


    s.dock = awful.popup {
        screen = s,
        type = "popup_menu",

        minimum_width = dpi(300),
        maximum_width = 0.8 * s.geometry.width,
        height = dpi(50),
        maximum_height = dpi(60),
        minimum_height = dpi(60),
        bg = beautiful.base,

        visible = true,
        ontop = true,

        shape = helpers.ui.rrect(20),
        shape_input = function(cr, w, h)
            h = input_shape_height and input_shape_height or h
            gears.shape.rectangle(cr, w, h)
        end,

        widget = wibox.widget {
            widget = wibox.container.margin,
            margins = dpi(5),
            {
                layout = wibox.layout.fixed.horizontal,
                spacing_widget = {
                    widget = wibox.widget.separator,
                    orientation = "vertical",
                    color = beautiful.inactive,
                    thickness = dpi(2),
                    span_ratio = 0.6,
                },
                spacing = dpi(12),
                launcher_icon,
                tasklist(s),
            }
        }
    }

    -- whether or not the dock is visible (duh)
    s.dock_visible = true

    -- the dock's geometry when not hidden
    local dock_bounds = {
        x = s.dock:geometry().x,
        y = s.geometry.y + s.geometry.height - dpi(70),
        height = dpi(70),
        width = s.dock:geometry().width,
    }

    -- update dock's x position when the width of the widget changes
    -- to keep it centered
    s.dock:connect_signal("property::width", function()
        local width = s.dock:geometry().width
        local x = s.geometry.x + s.geometry.width/2 - width/2

        -- update dock x position
        s.dock:geometry { x = x }

        -- update bounds
        dock_bounds.width = width
        dock_bounds.x = x
    end)

    -- animates dock's y position and opacity
    local animator = rubato.timed {
        duration = 0.3,
        easing = rubato.quadratic,
        intro = 0.05,
        outro = 0.2,
        pos = dpi(10),
        target = dpi(10),
        subscribed = function(pos)
            -- update dock x and y positions
            s.dock:geometry {
                y = s.geometry.y + s.geometry.height - pos,
            }

            -- update input shape
            input_shape_height = pos

            -- update dock opacity
            s.dock:set_opacity(math.max(0, (pos-dpi(10))/dpi(60)))
        end,
    }

    -- hide the dock
    function s.dock:hide()
        if s.dock.force_show then s.dock:show(); return end
        s.dock_visible = false
        animator.target = dpi(10)
    end

    -- show the dock
    function s.dock:show()
        s.dock_visible = true
        animator.target = dpi(70)
    end

    local is_hovered = false

    local function hide_if_client_overlaps(c)
        if c == nil or (c.first_tag and not c.first_tag.selected)
            or is_hovered or s.launcher_visible then
            s.dock:show()
            return
        end

        if c.fullscreen then
            animator.target = 0
            s.dock_visible = false
            return
        end
        if intersects(c:geometry(), dock_bounds) then
            s.dock:hide()
        else
            s.dock:show()
        end
    end

    local function check_focused()
        hide_if_client_overlaps(capi.client.focus)
    end

    -- signals to control whether or not the dock should be shown

    s.dock:connect_signal("mouse::enter", function()
        is_hovered = true
        s.dock:show()
    end)

    s.dock:connect_signal("mouse::leave", function()
        local mouse_coords = capi.mouse.coords()
        local mouse_bounds = {
            x = mouse_coords.x,
            y = mouse_coords.y,
            width = 1,
            height = 1,
        }
        if not intersects(mouse_bounds, dock_bounds) then
            is_hovered = false
            hide_if_client_overlaps(capi.client.focus)
        end
    end)

    client_signal("request::activate", function(c)
        if animator.target == 0 then return end
        hide_if_client_overlaps(c)
    end)
    client_signal("property::fullscreen", function(c)
        if c.fullscreen and c.screen == s then
            animator.target = 0
            s.dock_visible = false
        end
    end)
    client_signal("unfocus", function(c)
        -- if there's fullscreen clients on screen, don't show
        if c.fullscreen and c.screen == s then
            animator.target = 0
            s.dock_visible = false
        end
    end)

    client_signal("request::autoactivate", hide_if_client_overlaps)
    -- request::manage doesn't work???
    client_signal("manage", check_focused)
    client_signal("request::unmanage", check_focused)
    client_signal("tagged", check_focused)
    -- TODO: fix this. currently it does the exact opposite of the expected outcome
    client_signal("property::floating", check_focused)
    client_signal("request::geometry", hide_if_client_overlaps)
    client_signal("property::screen", hide_if_client_overlaps)

    awesome_signal("launcher::opened", s.dock.show)
    awesome_signal("launcher::closed", check_focused)

    tag_signal("property::selected", check_focused)
    tag_signal("property::layout", check_focused)

    return s.dock
end

