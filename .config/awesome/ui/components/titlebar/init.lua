local gears = require("gears")
local wibox = require("wibox")
local ruled = require("ruled")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local button = require("ui.widget.button")
local color = require("modules.lua-color")
local client_menu = require("ui.components.client_menu")

-- enable titlebars
ruled.client.append_rule {
    id         = "titlebars",
    rule_any   = { type = { "normal", "dialog" } },
    properties = { titlebars_enabled = true }
}

-- following two functions stolen from https://github.com/eromatiya/the-glorious-dotfiles/blob/master/config/awesome/floppy/module/titlebar.lua
local double_click_event_handler = function(double_click_event)
    if double_click_timer then
        double_click_timer:stop()
        double_click_timer = nil
        double_click_event()
        return
    end
    double_click_timer = gears.timer.start_new(
        0.20,
        function()
            double_click_timer = nil
            return false
        end
    )
end

local function create_click_events(c)
    local menu = client_menu(c)
    -- Titlebar button/click events
    local buttons = gears.table.join(
        awful.button(
            {},
            1,
            function()
                double_click_event_handler(function()
                    if c.floating then
                        c.floating = false
                        return
                    end
                    c.floating = not c.floating
                    c:raise()
                end)
                c:activate { context = "titlebar", action = "mouse_move" }
            end
        ),
        awful.button({}, 3, function() menu:show() end)
    )
    return buttons
end

client.connect_signal("request::titlebars", function(c)
    if c.class ~= nil then
        -- filter out gtk4 apps, firefox
        if c.class == "firefox" then return end
        if c.type == "dialog" then return end
        if c.class:match("org.gnome") then return end
    end

    local close_button = button {
        on = true,
        bg = beautiful.error,
        hover_bg = color(beautiful.error):mix(color(beautiful.text), 0.6),
        width = dpi(18),
        height = dpi(18),
        shape = gears.shape.circle,
        on_release = function(_, _, _, _, b)
            if b ~= 1 then return end
            c:kill()
        end,
    }

    local max_button = button {
        on = true,
        bg = beautiful.warn2,
        hover_bg = color(beautiful.warn2):mix(color(beautiful.text), 0.6),
        width = dpi(18),
        height = dpi(18),
        shape = gears.shape.circle,
        on_release = function(_, _, _, _, b)
            if b ~= 1 then return end
            c.maximized = not c.maximized
        end
    }

    local float_button = button {
        on = true,
        bg = beautiful.success,
        hover_bg = color(beautiful.success):mix(color(beautiful.text), 0.6),
        width = dpi(18),
        height = dpi(18),
        shape = gears.shape.circle,
        on_release = function(_, _, _, _, b)
            if b ~= 1 then return end
            c.floating = not c.floating
        end
    }

    -- gray out titlebuttons when not focused
    c:connect_signal("unfocus", function()
        close_button:set_bg(beautiful.inactive)
        max_button:set_bg(beautiful.inactive)
        float_button:set_bg(beautiful.inactive)
    end)
    -- restore colors when focused again
    c:connect_signal("focus", function()
        close_button:set_bg(beautiful.error)
        max_button:set_bg(beautiful.warn2)
        float_button:set_bg(beautiful.success)
    end)

    local titlebar = awful.titlebar(c, {
        position = "top",
        bg = beautiful.base,
        size = dpi(32),
    })
    titlebar:setup {
        widget = wibox.layout.stack,
        {
            layout = wibox.layout.align.horizontal,
            expand = "inside",
            {
                widget = wibox.container.margin,
                left = dpi(8),
                {
                    widget = wibox.container.place,
                    valign = "center",
                    halign = "center",
                    {
                        widget = awful.titlebar.widget.iconwidget(c),
                        forced_width = dpi(24),
                    }
                }
            },
            {
                layout = wibox.layout.flex.horizontal,
                buttons = create_click_events(c),
            },
            {
                widget = wibox.container.margin,
                right = dpi(11),
                {
                    widget = wibox.container.place,
                    {
                        layout = wibox.layout.fixed.horizontal,
                        spacing = dpi(13),
                        -- TODO: make these two disappear on modal dialogs
                        float_button,
                        max_button,
                        close_button,
                    }
                }
            },
        },
        {
            widget = awful.titlebar.widget.titlewidget(c),
            halign = "center",
            valign = "center",
            font = beautiful.font,
        },
    }
end)
