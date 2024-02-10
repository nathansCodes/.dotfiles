-------------------------------------------
-- @author https://github.com/Kasper24
-- @copyright 2021-2022 Kasper24
-------------------------------------------

local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local wibox = require("wibox")
local button = require("ui.widget.button")
local beautiful = require("beautiful")
local helpers = require("helpers")
local dpi = beautiful.xresources.apply_dpi
local setmetatable = setmetatable
local ipairs = ipairs
local capi = { awesome = awesome, mouse = mouse, tag = tag }

local menu = { mt = {} }

function menu:set_pos(args)
	args = args or {}

	local coords = args.coords
	local wibox = args.wibox
	local widget = args.widget
	local offset = args.offset or { x = 0, y = 0 }

	if offset.x == nil then
		offset.x = 0
	end
	if offset.y == nil then
		offset.y = 0
	end

	local screen_workarea = awful.screen.focused().workarea
	local screen_w = screen_workarea.x + screen_workarea.width
	local screen_h = screen_workarea.y + screen_workarea.height

	if not coords and wibox and widget then
		coords = helpers.ui.get_widget_geometry(wibox, widget)
	else
		coords = args.coords or capi.mouse.coords()
	end

	if coords.x + self.width > screen_w then
		if self.parent_menu ~= nil then
			self.x = coords.x - self.width - self.parent_menu.width - offset.x
		else
			self.x = coords.x - self.width + offset.x
		end
	else
		self.x = coords.x + offset.x
	end

	if coords.y + self.height > screen_h then
		self.y = screen_h - self.height + offset.y
	else
		self.y = coords.y + offset.y
	end
end

function menu:hide_parents_menus()
	if self.parent_menu ~= nil then
		self.parent_menu:hide(true)
	end
end

function menu:hide_children_menus()
	for _, button in ipairs(self.widget.children) do
		if button.sub_menu ~= nil then
			button.sub_menu:hide()
		end
	end
end

function menu:hide(hide_parents)
	if self.visible == false then
		return
	end

	-- Hide self
	self.visible = false

	-- Hides all child menus
	self:hide_children_menus()

	if hide_parents == true then
		self:hide_parents_menus()
	end
end

function menu:show(args)
	if self.visible == true then
		return
	end

	self.can_hide = false

	gtimer {
		timeout = 0.1,
		autostart = true,
		call_now = false,
		single_shot = true,
		callback = function()
			self.can_hide = true
		end,
	}

	-- Hide sub menus belonging to the menu of self
	if self.parent_menu ~= nil then
		for _, button in ipairs(self.parent_menu.widget.children) do
			if button.sub_menu ~= nil and button.sub_menu ~= self then
				button.sub_menu:hide()
			end
		end
	end

	self:set_pos(args)
	self.visible = true

	capi.awesome.emit_signal("menu::toggled_on", self)
end

function menu:toggle(args)
	if self.visible == true then
		self:hide()
	else
		self:show(args)
	end
end

function menu:add(widget)
	if widget.sub_menu then
		widget.sub_menu.parent_menu = self
	end
	widget.menu = self
	self.widget:add(widget)
end

function menu:remove(widget)
	self.widget:remove(widget)
end

function menu:reset()
	self.widget:reset()
end

function menu.menu(widgets, width)
	local widget = awful.popup {
		x = 32500,
		type = "menu",
		visible = false,
		ontop = true,
		minimum_width = width or dpi(300),
		maximum_width = width or dpi(300),
		shape = helpers.ui.rrect(10),
		bg = beautiful.surface,
		widget = wibox.layout.fixed.vertical,
	}
	gtable.crush(widget, menu, true)

	awful.mouse.append_client_mousebinding(awful.button({ "Any" }, 1, function()
		if widget.can_hide == true then
			widget:hide(true)
		end
	end))

	awful.mouse.append_client_mousebinding(awful.button({ "Any" }, 3, function()
		if widget.can_hide == true then
			widget:hide(true)
		end
	end))

	awful.mouse.append_global_mousebinding(awful.button({ "Any" }, 1, function()
		if widget.can_hide == true then
			widget:hide(true)
		end
	end))

	awful.mouse.append_global_mousebinding(awful.button({ "Any" }, 3, function()
		if widget.can_hide == true then
			widget:hide(true)
		end
	end))

	capi.tag.connect_signal("property::selected", function()
		widget:hide(true)
	end)

	capi.awesome.connect_signal("menu::toggled_on", function(menu)
		if menu ~= widget and menu.parent_menu == nil then
			widget:hide(true)
		end
	end)

	for _, menu_widget in ipairs(widgets) do
		widget:add(menu_widget)
	end

	return widget
end

function menu.sub_menu_button(args)
	args = args or {}

	args.icon = args.icon or nil
	args.icon_size = args.icon_size or 16
    args.icon_color = args.icon_color or beautiful.accent
	args.text = args.text or ""
	args.image = args.image
	args.text_size = args.text_size or 12
	args.sub_menu = args.sub_menu or nil

    local icon
	if args.icon ~= nil then
		icon = wibox.widget {
            widget = wibox.widget.textbox,
			font = beautiful.icon_font .. "Bold " .. args.icon_size,
			markup = helpers.ui.colorize_text(args.icon, args.icon_color),
            halign = "center",
		}
	elseif args.image ~= nil then
		icon = wibox.widget {
			widget = wibox.widget.imagebox,
			image = args.image,
            forced_width = dpi(20),
            forced_height = math.min(dpi(args.icon_size), dpi(20)),
            halign = "center",
            valign = "center",
		}
	end

    local text_widget = wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.font .. tostring(args.text_size),
        text = args.text,
    }

	local second_text_widget = args.secondary_text ~= nil and wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.font .. "SemiBold " .. args.text_size-1,
		markup = helpers.ui.colorize_text(args.secondary_text, beautiful.inactive),
        halign = "right",
	} or nil


    local widget = button {
        bg = gears.color.transparent,
        margins = dpi(5),
        height = dpi(45),
        shape = helpers.ui.rrect(10),
        on_mouse_enter = function(self, widget)
            local coords = helpers.ui.get_widget_geometry(self.menu, self)
            coords.x = coords.x + self.menu.x + self.menu.width
            coords.y = coords.y + self.menu.y
            args.sub_menu:show({ coords = coords, offset = { x = 5 } })
        end,
        widget = wibox.widget {
            widget = wibox.container.margin,
            margins = dpi(5),
            {
                layout = wibox.layout.fixed.horizontal,
                fill_space = true,
                spacing = dpi(15),
                icon,
                text_widget,
                {
                    widget = wibox.container.place,
                    halign = "right",
                    {
                        layout = wibox.layout.fixed.horizontal,
                        spacing = dpi(10),
                        second_text_widget,
                        {
                            widget = wibox.widget.textbox,
                            font = beautiful.icon_font .. "22",
                            halign = "right",
                            text = "\u{eac9}",
                        },
                    }
                }
            }
        },
    }

	widget.sub_menu = args.sub_menu

	return widget
end

function menu.button(args)
	args = args or {}

	args.icon = args.icon or nil
	args.icon_size = args.icon_size or 16
    args.icon_color = args.icon_color or beautiful.second_accent
	args.image = args.image
	args.text = args.text or ""
	args.text_size = args.text_size or 12
	args.on_press = args.on_press or nil

	local icon = nil

	if args.icon ~= nil then
		icon = wibox.widget {
            widget = wibox.widget.textbox,
			font = beautiful.icon_font .. "Bold " .. args.icon_size,
			markup = helpers.ui.colorize_text(args.icon, args.icon_color),
            halign = "center",
		}
	elseif args.image ~= nil then
		icon = wibox.widget {
			widget = wibox.widget.imagebox,
			image = args.image,
            halign = "center",
		}
	end

	local text_widget = wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.font .. args.text_size,
		text = args.text,
	}

	local second_text_widget = args.secondary_text ~= nil and wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.font .. "SemiBold " .. args.text_size-1,
		markup = helpers.ui.colorize_text(args.secondary_text, beautiful.inactive),
        halign = "right",
	} or nil


    return button {
        bg = gears.color.transparent,
        margins = dpi(5),
        height = dpi(45),
        shape = helpers.ui.rrect(10),
        on_release = function(self)
            self.menu:hide(true)
            args.on_press(self, text_widget)
        end,
        widget = wibox.widget {
            widget = wibox.container.margin,
            margins = dpi(5),
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(15),
                fill_space = true,
                icon,
                text_widget,
                second_text_widget,
            }
        },
    }
end

function menu.separator()
	return wibox.widget {
		widget = wibox.container.margin,
		top = dpi(5),
		bottom = dpi(5),
        left = dpi(10),
        right = dpi(10),
		{
			widget = wibox.widget.separator,
			forced_height = dpi(2),
			orientation = "horizontal",
			thickness = dpi(1),
			color = beautiful.highlight_low,
		},
	}
end

function menu.mt:__call(...)
	return menu.menu(...)
end

return setmetatable(menu, menu.mt)

