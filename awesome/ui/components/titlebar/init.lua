local gears = require("gears")
local wibox = require("wibox")
local ruled = require("ruled")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local button = require("ui.widget.button")
local client_menu = require("ui.components.client_menu")

-- enable titlebars
ruled.client.append_rule {
    id         = "titlebars",
    rule_any   = { type = { "normal", "dialog" } },
    properties = { titlebars_enabled = true      }
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
				c:activate {context = "titlebar", action = "mouse_move"}
			end
		),
		awful.button({}, 3, function() menu:show() end)
	)
	return buttons
end

client.connect_signal("request::titlebars", function(c)
    -- filter out firefox
    if c.class == "firefox" then return end

    local close_button = button {
        on = true,
        bg = beautiful.error,
        width = dpi(16),
        height = dpi(16),
        shape = gears.shape.circle,
        on_release = function(_, _, _, _, b)
            if b ~= 1 then return end
            c:kill()
        end,
    }

    local max_button = button {
        on = true,
        bg = beautiful.warn2,
        width = dpi(16),
        height = dpi(16),
        shape = gears.shape.circle,
        on_release = function(_, _, _, _, b)
            if b ~= 1 then return end
            c.maximized = not c.maximized
        end
    }

    local float_button = button {
        on = true,
        bg = beautiful.success,
        width = dpi(16),
        height = dpi(16),
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
    })
    titlebar:setup {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        {
            widget = wibox.container.margin,
            top = dpi(5),
            left = dpi(8),
            bottom = dpi(2),
            awful.titlebar.widget.iconwidget(c),
        },
        {
            layout = wibox.layout.fixed.horizontal,
            buttons = create_click_events(c),
            fill_space = true,
            {
                widget = awful.titlebar.widget.titlewidget(c),
                halign = "center",
                valign = "center",
                font = beautiful.font,
            }
        },
        {
            widget = wibox.container.margin,
            top = dpi(3),
            right = dpi(8),
            bottom = dpi(2),
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(10),
                float_button,
                max_button,
                close_button,
            }
        },
    }
end)

