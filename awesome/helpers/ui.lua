local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local gshape = gears.shape
local gstring = gears.string
local gmatrix = gears.matrix
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local _ui = {}

--- Changes the color of text
--- `Note:` make sure to use this with `markup`, not `text`
--- @param text string the text to colorize
--- @return string markup the resulting markup
function _ui.colorize_text(text, color)
    if color == "" or type(color) ~= "string" then
        color = "#ffffff"
    end

	return "<span foreground='" .. color .. "'>" .. gstring.xml_unescape(text) .. "</span>"
end

--- Makes text bold
--- `Note:` make sure to use this with `markup`, not `text`
--- @param text string the text to bold
--- @return string markup the resulting markup
function _ui.bold(text)
    return "<b>"..gstring.xml_unescape(text).."</b>"
end

--- Makes text italic
--- `Note:` make sure to use this with `markup`, not `text`
--- @param text string the text to italicise
--- @return string markup the resulting markup
function _ui.italic(text)
    return "<i>"..gstring.xml_unescape(text).."</i>"
end

--- A rounded rect helper function
--- @param radius number the border radius
--- @return function shape the `gears.shape` function
function _ui.rrect(radius)
    return function(cr, w, h)
        gshape.rounded_rect(cr, w, h, dpi(radius))
    end
end

--- Creates a partially rounded rect with custom corner radiuses
--- @param tl number the top-left corner radius
--- @param tr number the top-right corner radius
--- @param br number the bottom-right corner radius
--- @param bl number the bottom-left corner radius
--- @return function shape the `gears.shape` function
function _ui.prrect(tl, tr, br, bl)
    tl = dpi(tl) or dpi(10)
    tr = dpi(tr) or dpi(10)
    br = dpi(br) or dpi(10)
    bl = dpi(bl) or dpi(10)

    return function(cr, w, h)
        if w / 2 < tl then tl = w / 2 end
        if w / 2 < tr then tr = w / 2 end
        if w / 2 < bl then bl = w / 2 end
        if w / 2 < br then br = w / 2 end

        if h / 2 < tl then tl = h / 2 end
        if h / 2 < tr then tr = h / 2 end
        if h / 2 < bl then bl = h / 2 end
        if h / 2 < br then br = h / 2 end

        cr:move_to(0, tl)

        cr:arc( tl  , tl  ,     tl,    math.pi   , 3*(math.pi/2) )
        cr:arc( w-tr, tr  ,     tr, 3*(math.pi/2),    math.pi*2  )
        cr:arc( w-br, h-br,     br,    math.pi*2 ,    math.pi/2  )
        cr:arc( bl  , h-bl,     bl,    math.pi/2 ,    math.pi    )

        cr:close_path()
    end
end

--- Creates a circle of radius `r`
--- @param r number the circle's radius
--- @param color string the color hex code
--- @return wibox.container.background circle the created circle
function _ui.circle(r, color)
    return wibox.widget {
        widget = wibox.container.background,
        forced_width = dpi(r),
        forced_height = dpi(r),
        shape = gears.shape.circle,
        bg = color,
    }
end

-- I uhh... I forgot where I stole this from 💀
local function _get_widget_geometry(_hierarchy, widget)
	local width, height = _hierarchy:get_size()
	if _hierarchy:get_widget() == widget then
		-- Get the extents of this widget in the device space
		local x, y, w, h = gmatrix.transform_rectangle(_hierarchy:get_matrix_to_device(), 0, 0, width, height)
		return { x = x, y = y, width = w, height = h, hierarchy = _hierarchy }
	end

	for _, child in ipairs(_hierarchy:get_children()) do
		local ret = _get_widget_geometry(child, widget)
		if ret then
			return ret
		end
	end
end

--- Get the geometry of a widget
--- @param wibox wibox the wibox containing the widget.
--- @param widget wibox.widget the widget to get the geometry from.
--- @return table geometry the widget's geometry
function _ui.get_widget_geometry(wibox, widget)
	return _get_widget_geometry(wibox._drawable._widget_hierarchy, widget)
end

function _ui.add_tag(opts)
    opts.layout = opts.layout or awful.layout.suit.tile
    opts.index = opts.index or #opts.screen.tags + 1
    opts.name = opts.name or tostring(opts.index)
    opts.selected = opts.selected or false

    awful.tag.add(opts.icon, {
        screen = opts.screen,
        icon = opts.icon,
        desc = opts.desc,
        layout = opts.layout,
        index = opts.index,
        selected = opts.selected,
    })
end

--- Centers a widget
--- @param w wibox.widget the widget to center
function _ui.center(w)
    return wibox.widget {
        widget = wibox.container.place,
        w,
    }
end

--- Override a function on a widget(like `:draw()`, `:layout()`, etc)
--- @param widget wibox.widget The widget
--- @tparam table overrides 
--- @return wibox.widget widget the widget with the overriden methods
function _ui.widget_override(widget)
    local base_widget = wibox.widget(widget)
        or wibox.widget.base.make_widget(nil, nil, {enable_properties=true})

    gears.table.crush(base_widget, widget.overrides, true)

    return base_widget
end

return _ui

