local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local gtable = gears.table
local naughty = require("naughty")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local function create_child_widget(child, margins)
    return wibox.widget {
        widget = wibox.container.margin,
        margins = dpi(margins),
        child,
    }
end

local connected_rects = {}

function connected_rects.rect(x, y, width, height, widget)
    local rect_table = {}

    function rect_table:connect_at(position, offset, width, height, widget)
        if widget == nil then
            return function(child)
                table.insert(rect_table, {
                    position = position,
                    offset = offset,
                    width = width,
                    height = height,
                    child = wibox.widget.base.make_widget_from_value(child),
                })
                return rect_table
            end
        else
            table.insert(rect_table, {
                position = position,
                offset = offset,
                width = width,
                height = height,
                child = wibox.widget.base.make_widget_from_value(widget),
            })
            return rect_table
        end
    end

    if widget == nil then
        return function(child)
            table.insert(rect_table, {
                x = x,
                y = y,
                width = width,
                height = height,
                child = wibox.widget.base.make_widget_from_value(child),
            })
            return rect_table
        end
    else
        table.insert(rect_table, {
            x = x,
            y = y,
            width = width,
            height = height,
            child = wibox.widget.base.make_widget_from_value(widget),
        })
        return rect_table
    end
end

local connected_rect = {}

local function draw_corner(cr, kind, x, y, radius, reverse)
    reverse = reverse or false

    local function top_left()
        if radius == 0 then
            cr:line_to(x, y)
            return
        end

        if reverse then
            cr:arc_negative(x + radius, y + radius, radius, 1.5*math.pi, math.pi)
        else
            cr:arc(x + radius, y + radius, radius, math.pi, 1.5*math.pi)
        end
    end

    local function top_right()
        if radius == 0 then
            cr:line_to(x, y)
            return
        end

        if reverse then
            cr:arc_negative(x - radius, y + radius, radius, 0, 1.5*math.pi)
        else
            cr:arc(x - radius, y + radius, radius, 1.5*math.pi, 0)
        end
    end

    local function bottom_right()
        if radius == 0 then
            cr:line_to(x, y)
            return
        end

        if reverse then
            cr:arc_negative(x - radius, y - radius, radius, math.pi/2, 0)
        else
            cr:arc(x - radius, y - radius, radius, 0, math.pi/2)
        end
    end

    local function bottom_left()
        if radius == 0 then
            cr:line_to(x, y)
            return
        end

        if reverse then
            cr:arc_negative(x + radius, y - radius, radius, math.pi, math.pi/2)
        else
            cr:arc(x + radius, y - radius, radius, math.pi/2, math.pi)
        end
    end

    if     kind == "top_left"     then top_left()
    elseif kind == "top_right"    then top_right()
    elseif kind == "bottom_right" then bottom_right()
    elseif kind == "bottom_left"  then bottom_left()
    end
end

local function get_corners(cr, self, x, y, i)
    local r = self[1][i]

    local top_left = r.position == "right" and { x=x, y=y }
                  or r.position == "bottom" and { x=x - r.width, y=y }
                  or r.position == "left" and { x=x - r.width, y=y - r.height }
                  or r.position == "top" and { x=x, y=y - r.height }

    function top_left:draw(radius, reverse)
        if reverse then
            draw_corner(cr, "bottom_left", self.x, self.y, radius, true)
        else
            draw_corner(cr, "top_left", self.x, self.y, radius)
        end
    end

    local top_right = r.position == "right" and { x=x + r.width, y=y }
                   or r.position == "bottom" and { x=x, y=y }
                   or r.position == "left" and { x=x, y=y - r.height }
                   or r.position == "top" and { x=x + r.width, y=y - r.height }

    function top_right:draw(radius, reverse)
        if reverse then
            draw_corner(cr, "top_left", self.x, self.y, radius, true)
        else
            draw_corner(cr, "top_right", self.x, self.y, radius)
        end
    end

    local bot_right = r.position == "right" and { x=x + r.width, y=y + r.height }
                   or r.position == "bottom" and { x=x, y=y + r.height }
                   or r.position == "left" and { x=x, y=y }
                   or r.position == "top" and { x=x + r.width, y=y }

    function bot_right:draw(radius, reverse)
        if reverse then
            draw_corner(cr, "top_right", self.x, self.y, radius, true)
        else
            draw_corner(cr, "bottom_right", self.x, self.y, radius)
        end
    end

    local bot_left = r.position == "right" and { x=x, y=y + r.height }
                  or r.position == "bottom" and { x=x - r.width, y=y + r.height }
                  or r.position == "left" and { x=x - r.width, y=y }
                  or r.position == "top" and { x=x, y=y }

    function bot_left:draw(radius, reverse)
        if reverse then
            draw_corner(cr, "bottom_right", self.x, self.y, radius, true)
        else
            draw_corner(cr, "bottom_left", self.x, self.y, radius)
        end
    end

    return {
        top_left = top_left,
        top_right = top_right,
        bottom_right = bot_right,
        bottom_left = bot_left,
    }
end

local function handle_inner(cr, self, x, y, width, height, border_radius, i)
    local current = self[1][i]
    local next = self[1][i+1]

    current.width = current.width == 0
                    and (current.position == "top" and width - x
                      or current.position == "right" and width - x
                      or current.position == "bottom" and width - x
                      or current.position == "left" and x) or current.width
    current.height = current.height == 0
                     and (current.position == "top" and y
                      or  current.position == "right" and height - y
                      or  current.position == "bottom" and height - y
                      or  current.position == "left" and 100) or current.height

    local positions_table = {
        top = function(x1, y1) return { x = x1 + next.offset, y = y1 } end,
        right = function(x1, y1) return { x = x1, y = y1 + next.offset } end,
        bottom = function(x1, y1) return { x = x1 - current.width + next.offset + next.width, y = y1 } end,
        left = function(x1, y1) return { x = x1, y = y1 - current.height + next.offset + next.height } end,
    }

    local positions = current.position == "top"    and { "left", "top", "right" }
                   or current.position == "right"  and { "top", "right", "bottom" }
                   or current.position == "bottom" and { "right", "bottom", "left" }
                   or current.position == "left"   and { "bottom", "left", "top" }
                   or {}

    local corners = get_corners(cr, self, x, y, i)

    local next_corner_radius = border_radius

    local reverse_corner = false

    for j, pos_str in pairs(positions) do
        local corner = pos_str == "top" and corners.top_left
                    or pos_str == "right" and corners.top_right
                    or pos_str == "bottom" and corners.bottom_right
                    or pos_str == "left" and corners.bottom_left

        if j ~= 1 and next_corner_radius ~= 0 then
            corner:draw(next_corner_radius, reverse_corner)
            reverse_corner = false
        end

        next_corner_radius = border_radius

        if next ~= nil and next.position == pos_str then
            local pos = positions_table[pos_str](corner.x, corner.y)

            if pos_str == "top" then
                local distance_to_corner = next.offset
                local radius = math.min(border_radius, distance_to_corner/2)

                cr:arc_negative(corner.x + distance_to_corner - radius, corner.y - radius, radius, math.pi/2, 0)
                handle_inner(cr, self, pos.x, pos.y, width, height, border_radius, i + 1)

                local distance_to_corner = (corner.x + current.width) - (corner.x + next.offset + next.width)
                if distance_to_corner == 0 then break end
                local radius = math.min(border_radius, math.abs(distance_to_corner)/2)
                if distance_to_corner > 0 then
                    cr:arc_negative(corner.x + current.width - distance_to_corner + radius, corner.y - radius, radius, math.pi, math.pi/2)
                else
                    cr:arc_negative(corner.x + current.width - distance_to_corner + radius, corner.y - radius, radius, 0, math.pi/2)
                    reverse_corner = true
                end
                next_corner_radius = radius
            elseif pos_str == "right" then
                local distance_to_corner = next.offset
                local radius = math.min(border_radius, distance_to_corner/2)

                cr:arc_negative(corner.x + radius, corner.y + distance_to_corner - radius, radius, math.pi, math.pi/2)
                handle_inner(cr, self, pos.x, pos.y, width, height, border_radius, i + 1)

                local distance_to_corner = (corner.y + current.height) - (corner.y + next.offset + next.height)
                if distance_to_corner == 0 then break end
                local radius = math.min(border_radius, math.abs(distance_to_corner)/2)
                if distance_to_corner > 0 then
                    cr:arc_negative(corner.x + radius, corner.y + next.offset + next.height + radius, radius, 1.5*math.pi, math.pi)
                else
                    cr:arc(corner.x + radius, corner.y + next.offset + next.height + radius, radius, math.pi/2, math.pi)
                    reverse_corner = true
                end
                next_corner_radius = radius
            elseif pos_str == "bottom" then
                local distance_to_corner = corner.x - ((corner.x - current.width) + next.offset + next.width)
                local radius = math.min(border_radius, distance_to_corner/2)

                cr:arc_negative(corner.x-distance_to_corner + radius, corner.y + radius, radius, 1.5*math.pi, math.pi)
                handle_inner(cr, self, pos.x, pos.y, width, height, border_radius, i + 1)

                local distance_to_corner = next.offset
                if distance_to_corner == 0 then break end
                local radius = math.min(border_radius, math.abs(distance_to_corner)/2)
                if distance_to_corner > 0 then
                    cr:arc_negative((corner.x - current.width) + next.offset - radius, corner.y + radius, radius, 0, 1.5*math.pi)
                else
                    cr:arc((corner.x - current.width) + next.offset + radius, corner.y + radius, radius, math.pi, 1.5*math.pi)
                    reverse_corner = true
                end
                next_corner_radius = radius
            elseif pos_str == "left" then
                local distance_to_corner = corner.y - ((corner.y - current.height) + next.offset + next.height)
                local radius = math.min(border_radius, distance_to_corner/2)

                cr:arc_negative(corner.x - radius, corner.y - distance_to_corner + radius, radius, 0, 1.5*math.pi)
                handle_inner(cr, self, pos.x, pos.y, width, height, border_radius, i + 1)

                local distance_to_corner = next.offset
                if distance_to_corner == 0 then break end
                local radius = math.min(border_radius, math.abs(distance_to_corner)/2)
                if distance_to_corner > 0 then
                    cr:arc_negative(corner.x - radius, (corner.y - current.height) + distance_to_corner - radius, radius, math.pi/2, 0)
                else
                    cr:arc(corner.x - radius, (corner.y - current.height) + distance_to_corner + radius, radius, 1.5*math.pi, 0)
                    reverse_corner = true
                end
                next_corner_radius = radius
            end
        end
    end
end

local function create_path(cr, self, width, height, border_radius)
    if #self[1] == 0 then
        gears.shape.rounded_rect(cr, width, height, border_radius)
        return
    end
    local first = self[1][1]
    local second = self[1][2]

    first.width = first.width == 0 and width or first.width
    first.height = first.height == 0 and height or first.height

    cr:move_to(first.x, first.y)

    local top_left_radius = border_radius
    local top_right_radius = border_radius
    if second ~= nil and second.position == "top" then
        local corner_x = first.x
        local corner_y = first.y
        local distance_to_corner = second.offset
        local radius = math.min(border_radius, distance_to_corner/2)

        top_left_radius = radius
        cr:arc_negative(corner_x + distance_to_corner - radius, corner_y - radius, radius, math.pi/2, 0)
        handle_inner(cr, cr, self, first.x + second.offset, first.y, width, height, border_radius, 2)

        local distance_to_corner = (corner_x + first.width) - (corner_x + second.offset + second.width)
        local radius = math.min(border_radius, distance_to_corner/2)
        cr:arc_negative(corner_x + first.width - distance_to_corner + radius, corner_y - radius, radius, math.pi, math.pi/2)
        top_right_radius = radius
    end

    local bottom_right_radius = border_radius
    if second ~= nil and second.position == "right" then
        local corner_x = first.x + first.width
        local corner_y = first.y
        local distance_to_corner = second.offset
        local radius = math.min(border_radius, distance_to_corner/2)

        draw_corner(cr, "top_right", corner_x, corner_y, math.min(top_right_radius, second.offset/2), border_radius)
        cr:arc_negative(corner_x + radius, corner_y + distance_to_corner - radius, radius, math.pi, math.pi/2)
        handle_inner(cr, cr, self, first.x + first.width, first.y + second.offset, width, height, border_radius, 2)

        local distance_to_corner = (corner_y + first.height) - (first.y + second.offset + second.height)
        local radius = math.min(border_radius, distance_to_corner/2)
        cr:arc_negative(corner_x + radius, corner_y + second.offset + second.height + radius, radius, 1.5*math.pi, math.pi)
        bottom_right_radius = radius
    else
        draw_corner(cr, "top_right", first.x + first.width, first.y, top_right_radius)
    end

    local bottom_left_radius = border_radius
    if second ~= nil and second.position == "bottom" then
        local corner_x = first.x + first.width
        local corner_y = first.y + first.height
        local distance_to_corner = corner_x - (first.x + second.offset + second.width)
        local radius = math.min(border_radius, distance_to_corner/2)

        draw_corner(cr, "bottom_right", corner_x, corner_y, math.min(bottom_right_radius, radius))
        cr:arc_negative(corner_x-distance_to_corner + radius, corner_y + radius, radius, 1.5*math.pi, math.pi)
        handle_inner(cr, self, first.x + second.offset + second.width, corner_y, width, height, border_radius, 2)

        local distance_to_corner = second.offset
        local radius = math.min(border_radius, distance_to_corner/2)
        cr:arc_negative(first.x + second.offset - radius, corner_y + radius, radius, 0, 1.5*math.pi)
        bottom_left_radius = radius
    else
        draw_corner(cr, "bottom_right", first.x + first.width, first.y + first.height, bottom_right_radius)
    end

    if second ~= nil and second.position == "left" then
        local corner_x = first.x
        local corner_y = first.y + first.height
        local distance_to_corner = corner_y - (first.y + second.offset + second.height)
        local radius = math.min(border_radius, distance_to_corner/2)

        draw_corner(cr, "bottom_left", first.x, first.y + first.height, math.min(bottom_left_radius, radius))
        cr:arc_negative(corner_x - radius, corner_y - distance_to_corner + radius, radius, 0, 1.5*math.pi)
        handle_inner(cr, self, first.x, first.y + second.offset + second.height, width, height, border_radius, 2)

        local distance_to_corner = second.offset
        local radius = math.min(border_radius, distance_to_corner/2)
        cr:arc_negative(corner_x - radius, first.y + distance_to_corner - radius, radius, math.pi/2, 0)
        top_left_radius = radius
    else
        draw_corner(cr, "bottom_left", first.x, first.y + first.height, border_radius)
    end

    draw_corner(cr, "top_left", first.x, first.y, top_left_radius)

    cr:close_path()
end

-- There's probably a better way to do this
function connected_rect:before_draw_children(_, cr, width, height)
    local border_radius = self.args.border_radius or 0

    cr:set_source(gears.color(self.args.bg) or gears.color(beautiful.bg_normal))

    create_path(cr, self, width, height, border_radius)
    cr:fill()
end

-- draw border
function connected_rect:after_draw_children(_, cr, width, height)
    if not self.args.border_width then return end
    local border_radius = self.args.border_radius or 0

    cr:set_source(gears.color(self.args.border_color) or gears.color(beautiful.border_normal))

    create_path(cr, self, width, height, border_radius)

    cr:set_line_width(self.args.border_width)
    cr:stroke()
end

function connected_rect:layout(_, width, height)
    local result = wibox.widget { layout = wibox.layout.manual }

    local inner_margin = self.args.inner_margin or dpi(10)

    local x = self[1][1].x
    local y = self[1][1].y

    local rect_width = self[1][1].width == 0 and width or self.rects[1].width
    local rect_height = self[1][1].height == 0 and height or self.rects[1].height

    local child = create_child_widget(self[1][1].child, inner_margin + (self.args.border_radius or 0))
    result:add_at(child, {
        x = x,
        y = y,
        width = rect_width,
        height = rect_height,
    })

    for i, rect in ipairs(self[1]) do
        if i == 1 then goto continue end
        x = rect.position == "top" and x + rect.offset
            or rect.position == "right" and x + rect_width
            or rect.position == "bottom" and x + rect.offset
            or rect.position == "left" and x - rect.width

        y = rect.position == "top" and y - rect.height
            or rect.position == "right" and y + rect.offset
            or rect.position == "bottom" and y + rect_height
            or rect.position == "left" and y + rect.offset

        rect_width = rect.width == 0
            and (rect.position == "top" and math.abs(width - x)
              or rect.position == "right" and math.abs(width - x)
              or rect.position == "bottom" and math.abs(width - x)
              or rect.position == "left" and x) or rect.actual_width or rect.width
        rect_height = rect.height == 0
             and (rect.position == "top" and y
              or  rect.position == "right" and height - y
              or  rect.position == "bottom" and height - y
              or  rect.position == "left" and height - y) or rect.actual_height or rect.height


        local current_child = create_child_widget(rect.child, inner_margin)
        result:add_at(current_child, {
            x = x,
            y = y,
            width = rect_width,
            height = rect_height,
        })

        ::continue::
    end
    return { wibox.widget.base.place_widget_at(result, 0, 0, width, height) }
end

function connected_rect:fit(_, width, height)
    for _, r in ipairs(self[1]) do
        r.actual_width = r.width == 0
            and (r.position == "top" and math.abs(width - r.x)
              or r.position == "right" and math.abs(width - r.x)
              or r.position == "bottom" and math.abs(width - r.x)
              or r.position == "left" and r.x) or r.width
        r.actual_height = r.height == 0
             and (r.position == "top" and r.y
              or  r.position == "right" and height - r.y
              or  r.position == "bottom" and height - r.y
              or  r.position == "left" and height - r.y) or r.height
    end
    return width, height
end

function connected_rects.new(args)
    return gears.protected_call(function()
    local ret = wibox.widget.base.make_widget(nil, nil, {enable_properties = true})
    gtable.crush(ret, connected_rect, true)
    local rects = {}
    if type(args[1]) == "table" then
        -- filter out named props (e.g. connect_at)
        for i, v in ipairs(args[1]) do
            table.insert(rects, i, v)
        end
    end
    ret[1] = rects
    ret.args = args
    ret.forced_height = args.forced_height
    ret.forced_width = args.forced_width

    return ret
end, function(e) naughty.notification { text = e } end)
end

return setmetatable(connected_rects, { __call = function(_, ...)
    return connected_rects.new(...)
end })

