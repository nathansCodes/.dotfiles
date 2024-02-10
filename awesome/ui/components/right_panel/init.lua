local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local rubato = require("modules.rubato")

local helpers = require("helpers")
local overflow = require("ui.layout.overflow")
local test = require("ui.components.right_panel.test")
local bluetooth = require("ui.components.right_panel.bluetooth")

return function(s)
    -- used in the shape function to prevent
    -- the entire popup from flickering when sliding in/out
    local width

    s.right_panel = awful.popup {
        screen = s,
        type = "popup_menu",

        width = dpi(500),
        minimum_width = dpi(1),
        maximum_width = dpi(500),
        height = s.geometry.height - dpi(36),
        bg = beautiful.base,

        placement = function(w)
            (awful.placement.right + awful.placement.maximize_vertically)(w, {
                honor_padding = true,
                honor_workarea = true,
            })
        end,

        visible = true,
        ontop = true,
        opacity = 1,

        shape = function(cr, w, h)
            w = width and width or w
            cr:move_to(0, 0)
            cr:line_to(w, 0)
            cr:line_to(w, h)
            cr:arc_negative(0, h - 20, 20, math.pi/2, 0)
            cr:arc_negative(0, 20, 20, 0, 1.5*math.pi)
            cr:close_path()
        end,

        widget = wibox.widget {
            layout = overflow.horizontal,
            scrollbar_enabled = false,
            {
                widget = wibox.container.margin,
                left = dpi(30),
                right = dpi(10),
                bottom = dpi(10),
                {
                    widget = wibox.container.background,
                    shape = helpers.ui.rrect(20),
                    forced_width = dpi(460),
                    bg = beautiful.surface,
                    {
                        widget = wibox.container.margin,
                        margins = dpi(10),
                        bluetooth,
                    }
                }
            }
        }
    }
    s.right_panel_visible = false

    local animator = rubato.timed {
        duration = 0.5,
        intro = 0.1,
        outro = 0.2,
        pos = 0,
        easing = rubato.quadratic,
        subscribed = function(pos)
            if pos < 5 then
                s.right_panel.visible = false
            else
                s.right_panel.visible = true
            end
            width = math.max(pos, 1)
            s.right_panel:geometry {
                x = s.geometry.x + s.geometry.width - pos,
            }
        end,
    }

    function s.right_panel:toggle()
        s.right_panel_visible = not s.right_panel_visible
        if s.right_panel_visible then
            animator.target = dpi(500)
            s.right_panel.input_passthrough = false
        else
            animator.target = 0
            s.right_panel.input_passthrough = true
        end
    end

    return s.right_panel
end
