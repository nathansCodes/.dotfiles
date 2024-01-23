local gears = require("gears")
local wibox = require("wibox")
local ruled = require("ruled")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local button = require("ui.widget.button")
local menu = require("ui.widget.menu")

-- enable titlebars
ruled.client.append_rule {
    id         = "titlebars",
    rule_any   = { type = { "normal", "dialog" } },
    properties = { titlebars_enabled = true      }
}

local function create_menu(c)
    local tags_menu = menu { }

    -- add button for each tag
    for _, tag in ipairs(awful.screen.focused().tags) do
        tags_menu:add(menu.button {
            icon = tag.icon,
            icon_color = beautiful.third_accent,
            text = tag.name,
            secondary_text = "Super+Shift+"..tag.index,
            on_press = function()
                c:move_to_tag(tag)
            end,
        })
    end

    return menu {
        menu.button {
            icon = "\u{e5cd}",
            icon_color = beautiful.error,
            text = "Close",
            secondary_text = "Super+Q",
            on_press = function()
                c:kill()
            end
        },
        menu.button {
            icon = "\u{e069}",
            icon_color = beautiful.warn2,
            text = "Maximize",
            secondary_text = "Super+M",
            on_press = function(_, text_widget)
                c.maximized = not c.maximized
                if c.maximized then
                    text_widget:set_text("Unmaximize")
                else
                    text_widget:set_text("Maximize")
                end
            end
        },
        menu.button {
            icon = "\u{e931}",
            icon_color = beautiful.success,
            text = "Minimize",
            on_press = function()
                c.minimized = not c.minimized
            end
        },
        menu.separator(),
        menu.button {
            icon = "\u{e5d0}",
            icon_color = beautiful.accent,
            text = "Fullscreen",
            secondary_text = "Super+Shift+F",
            on_press = function()
                c.fullscreen = not c.fullscreen
            end
        },
        menu.button {
            icon = "\u{e6fa}",
            icon_color = beautiful.accent,
            text = c.floating and "Tile" or "Float",
            secondary_text = "Super+F",
            on_press = function(_, text_widget)
                c.floating = not c.floating
                if c.floating then
                    text_widget:set_text("Tile")
                else
                    text_widget:set_text("Float")
                end
            end
        },
        menu.sub_menu_button {
            icon = "\u{f742}",
            icon_color = beautiful.accent,
            text = "Move to tag",
            --secondary_text = "Super+Shift+#",
            sub_menu = tags_menu
        }
    }
end

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
		awful.button({}, 3, function() menu:show() end)
	)
	return buttons
end

client.connect_signal("request::titlebars", function(c)
    local close_button = button {
        on = true,
        bg_on = beautiful.error,
        bg_off = beautiful.inactive,
        width = dpi(17),
        height = dpi(17),
        shape = gears.shape.circle,
        on_release = function()
            c:kill()
        end,
    }

    local max_button = button {
        on = true,
        bg_on = beautiful.warn2,
        bg_off = beautiful.inactive,
        width = dpi(17),
        height = dpi(17),
        shape = gears.shape.circle,
        on_release = function()
            c.maximized = not c.maximized
        end
    }

    local min_button = button {
        on = true,
        bg_on = beautiful.success,
        bg_off = beautiful.inactive,
        width = dpi(17),
        height = dpi(17),
        shape = gears.shape.circle,
        on_release = function()
            c.minimized = not c.minimized
        end
    }

    local float_button = button {
        on = true,
        bg_on = beautiful.magenta,
        bg_off = beautiful.inactive,
        width = dpi(17),
        height = dpi(17),
        shape = gears.shape.circle,
        on_release = function()
            c.floating = not c.floating
        end
    }

    -- gray out titlebuttons when not focused
    c:connect_signal("unfocus", function()
        close_button:turn_off()
        max_button:turn_off()
        min_button:turn_off()
        float_button:turn_off()
    end)
    -- restore colors when focused again
    c:connect_signal("focus", function()
        close_button:turn_on()
        max_button:turn_on()
        min_button:turn_on()
        float_button:turn_on()
    end)

    local titlebar = awful.titlebar(c, {
        position = "right",
        bg = beautiful.base,
    })
    titlebar:setup {
        layout = wibox.layout.align.vertical,
        {
            widget = wibox.container.margin,
            margins = dpi(7),
            {
                layout = wibox.layout.fixed.vertical,
                spacing = dpi(8),
                close_button,
                max_button,
                min_button,
            }
        },
        {
            layout = wibox.layout.flex.vertical,
            buttons = create_click_events(c),

        },
        {
            widget = wibox.container.margin,
            margins = dpi(7),
            float_button,
        },
    }
end)

