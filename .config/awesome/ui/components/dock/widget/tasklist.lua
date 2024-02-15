local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local bling = require("modules.bling")

local pinned_apps = require("ui.components.dock.widget.pinned_apps")
local client_menu = require("ui.components.client_menu")

local capi = { awesome = awesome, client = client }

local function create_buttons()
    local menu
    return gears.table.join(
        awful.button({}, 1, function(c)
            if c == capi.client.focus then
                c.minimized = true
            else
                awful.tag.viewonly(c.first_tag) -- This line switches to the client's workspace
                c:emit_signal(
                    "request::activate",
                    "tasklist",
                    { raise = true }
                )
            end
        end),
        awful.button({}, 3, function(c)
            menu = menu or client_menu(c)
            menu:show()
        end),
        awful.button({}, 4, function()
            awful.client.focus.byidx(1)
        end),
        awful.button({}, 5, function()
            awful.client.focus.byidx(-1)
        end)
    )
end

return function(s)
    local pinned_apps = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        spacing = dpi(8),
        pinned_apps.firefox,
        pinned_apps.file_manager,
        pinned_apps.term,
        pinned_apps.steam,
        pinned_apps.libreoffice,
        pinned_apps.discord,
        pinned_apps.godot,
    }

    bling.widget.task_preview.enable {
        height = dpi(250),              -- The height of the popup
        width = dpi(250),               -- The width of the popup
        placement_fn = function(c) -- Place the widget using awful.placement (this overrides x & y)
            awful.placement.bottom(c, {
                margins = {
                    bottom = dpi(80)
                }
            })
        end,
    }


    local tasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.alltags,
        buttons = create_buttons(),
        style = {
            shape = gears.shape.rounded_rect,
        },
        layout = {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(10),
        },
        widget_template = {
            id = "background_role",
            widget = wibox.container.background,
            forced_width = dpi(50),
            forced_height = dpi(50),
            {
                widget = wibox.container.margin,
                margins = dpi(10),
                {
                    id = "clienticon",
                    widget = awful.widget.clienticon,
                    resize = true,
                },
            },
            create_callback = function(self, c, _, _)
                self:get_children_by_id("clienticon")[1].client = c
                self:connect_signal("mouse::enter", function()
                    capi.awesome.emit_signal("bling::task_preview::visibility",
                        s, true, c)
                end)
                self:connect_signal("mouse::leave", function()
                    capi.awesome.emit_signal("bling::task_preview::visibility",
                        s, false, c)
                end)
            end,
        }
    }

    return wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        spacing = dpi(10),
        spacing_widget = {
            widget = wibox.widget.separator,
            orientation = "vertical",
            color = beautiful.inactive,
            thickness = dpi(2),
            span_ratio = 0.6,
        },
        pinned_apps,
        tasklist,
    }
end

