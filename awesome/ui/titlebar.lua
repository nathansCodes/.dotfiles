local gears = require("gears")
local wibox = require("wibox")
local ruled = require("ruled")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi


-- enable titlebars
ruled.client.append_rule {
    id         = "titlebars",
    rule_any   = { type = { "normal", "dialog" } },
    properties = { titlebars_enabled = true      }
}

-- TODO: make a custom menu widget that actually looks good
local function create_menu(c)
    return awful.menu {
        items = {
            { "On top", function() c.ontop = not c.ontop end }
        }
    }
end

-- following two function stolen from https://github.com/eromatiya/the-glorious-dotfiles/blob/master/config/awesome/floppy/module/titlebar.lua
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

local create_click_events = function(c)
    local menu = create_menu(c)
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
				c:activate {context = 'titlebar', action = 'mouse_move'}
			end
		),
		awful.button(
			{},
			3,
			function()
				--menu:toggle()
			end
		)
	)
	return buttons
end

client.connect_signal("request::titlebars", function(c)
    if c.class:match("org.gnome") then return end

    local titlebar = awful.titlebar(c, {
        position = "right",
        bg = c.name == nil and beautiful.bg_focus or
                           c.name == "Alacritty" and beautiful.bg_normal .. "cc"
                           or  beautiful.bg_focus,
    })
    titlebar:setup {
        layout = wibox.layout.align.vertical,
        {
            widget = wibox.container.margin,
            margins = dpi(7),
            {
                layout = wibox.layout.fixed.vertical,
                spacing = dpi(6),
                awful.titlebar.widget.closebutton(c),
                awful.titlebar.widget.maximizedbutton(c),
                awful.titlebar.widget.minimizebutton(c),
            }
        },
        {
            layout = wibox.layout.flex.vertical,
            buttons = create_click_events(c),
        },
        {
            widget = wibox.container.margin,
            margins = dpi(7),
            awful.titlebar.widget.floatingbutton(c),
        },
    }
end)

