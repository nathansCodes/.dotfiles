local wibox = require("wibox")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local rubato = require("modules.rubato")

local button = require("ui.widget.button")
local helpers = require("helpers")

local builder = {}

function builder.app_icon(icon)
    icon = icon or gears.color.recolor_image(gfs.get_configuration_dir()
                    .. "ui/icons/notification.svg", beautiful.text)

    return wibox.widget {
        id = "app_icon",
        widget = wibox.widget.imagebox,
        clip_shape = gears.shape.rounded_rect,
        resize = true,
        forced_height = dpi(25),
        forced_width = dpi(25),
        image = icon,
    }
end

function builder.image(image)
    if image == nil then return nil end
    local widget = wibox.widget {
        id = "image",
        point = { x = dpi(10), y = 0, width = dpi(120), height = dpi(67.5) },
        widget = wibox.widget.imagebox,
        clip_shape = gears.shape.rounded_rect,
        resize = true,
        valign = "center",
        halign = "center",
        horizontal_fit_policy = "auto",
        vertical_fit_policy = "auto",
        image = image,
    }

    return widget
end

function builder.app_name(app_name)
    return wibox.widget {
        widget = wibox.container.constraint,
        width = dpi(130),
        height = dpi(30),
        srategy = "max",
        {
            widget = wibox.widget.textbox,
            markup = helpers.ui.colorize_text(app_name, beautiful.inactive),
            halign = "right",
            valign = "center",
            font = beautiful.font .. "SemiBold 11",
        }
    }
end

function builder.title(title)
    return wibox.widget {
        widget = wibox.widget.textbox,
        markup = title,
        ellipsize = "end",
        font = beautiful.font .. "Bold 12",
    }
end

function builder.message(message)
    return wibox.widget {
        id = "message",
        widget = wibox.widget.textbox,
        markup = message,
        valign = "top",
        ellipsize = "middle",
        font = beautiful.font .. "11",
    }
end

function builder.actions(n)
    if #n.actions == 0 then return end
    local action_layout = wibox.widget {
        layout = wibox.layout.flex.horizontal,
        spacing = dpi(5),
    }

    for _, action in ipairs(n.actions) do
        local icon

        -- if action.icon is a string
        if type(action.icon) == "string"
        -- and isn't a filepath
        and not gfs.file_readable(action.icon)
        -- and isn't an svg (I know, very simple way of checking if it's an svg)
        and not gears.string.startswith(action.icon, "<") then
            -- then it's most likely a fonticon
            icon = wibox.widget {
                widget = wibox.widget.textbox,
                font   = beautiful.icon_font .. "SemiBold 14",
                markup = action.icon,
                valign = "center",
                halign = "center",
            }
        else
            -- otherwise it's an image
            icon = wibox.widget {
                widget = wibox.widget.imagebox,
                image = action.icon,
            }
        end

        local action_button = button {
            bg = beautiful.highlight_low,
            hover_bg = beautiful.highlight_med,
            shape = gears.shape.rounded_bar,
            on_press = function()
                action:emit_signal("invoked", n)
            end,
            widget = wibox.widget {
                widget = wibox.container.place,
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(5),
                    icon,
                    {
                        widget = wibox.widget.textbox,
                        font   = beautiful.font .. "SemiBold 11",
                        text   = action.name,
                        valign = "center",
                        halign = "center",
                    }
                }
            },
        }
        action_layout:add(action_button)
    end

    return wibox.widget {
        widget = wibox.container.place,
        valign = "bottom",
        content_fill_horizontal = true,
        {
            widget = wibox.container.margin,
            top = dpi(5),
            bottom = dpi(10),
            left = dpi(10),
            right = dpi(10),
            forced_height = dpi(45),
            action_layout,
        }
    }
end

function builder.close_button(n)
    local arc = wibox.widget {
        widget = wibox.container.arcchart,
        thickness = dpi(4),
        rounded_edge = true,
        start_angle = 1.5*math.pi,
        colors = { beautiful.error },
        border_width = 0,
        max_value = 1,
        min_value = 0.05,
        value = 1,
        forced_width = dpi(30),
        forced_height = dpi(30),
    }

    local close_button = button {
        shape = gears.shape.circle,
        animate = false,
        on_release = function() n:destroy() end,
        widget = {
            widget = wibox.layout.stack,
            arc,
            {
                widget = wibox.widget.textbox,
                markup = helpers.ui.colorize_text("\u{e5cd}", beautiful.error),
                valign = "center",
                halign = "center",
                font = beautiful.icon_font .. "Bold 16",
            },
        }
    }

    -- there's probably a way to merge this into the timeout animation,
    -- but I'm too lazy to figure out how
    local hover_fade_out = rubato.timed {
        duration = 0.5,
        easing = rubato.linear,
        pos = 1,
        subscribed = function(pos)
            arc:set_opacity(pos)
        end,
    }

    function close_button:fade_out()
        hover_fade_out.target = 0
    end

    -- create animator for timeout arc
    local timeout_anim = rubato.timed {
        duration = n.timeout,
        easing = rubato.none,
        pos = 1,
        subscribed = function(pos)
            arc:set_value(pos)
            -- start fading out the arc when the timeout is almost over
            if pos <= 0.25 and hover_fade_out.target == 1 then
                hover_fade_out.target = 0
            end
        end,
    }

    -- start the animation
    timeout_anim.target = 0

    return close_button
end

local function parse_to_seconds(time)
	local hourInSec = tonumber(string.sub(time, 1, 2)) * 3600
	local minInSec = tonumber(string.sub(time, 4, 5)) * 60
	local getSec = tonumber(string.sub(time, 7, 8))
	return (hourInSec + minInSec + getSec)
end

function builder.notif_time()
	local time_of_pop = os.date("%H:%M:%S")
	local exact_time = os.date("%I:%M %p")
	local exact_date_time = os.date("%b %d, %I:%M %p")

    local notifbox_timepop = wibox.widget {
		id = "time_pop",
		markup = nil,
		font = beautiful.font .. "SemiBold 11",
		align = "left",
		valign = "center",
		visible = true,
		widget = wibox.widget.textbox
	}

    local function set_text(t)
        notifbox_timepop:set_markup(helpers.ui.colorize_text(t, beautiful.inactive))
    end

	local time_of_popup = gears.timer {
		timeout   = 60,
		call_now  = true,
		autostart = true,
		callback  = function()
			local time_difference = nil

			time_difference = parse_to_seconds(os.date("%H:%M:%S")) - parse_to_seconds(time_of_pop)
			time_difference = tonumber(time_difference)

			if time_difference < 60 then
				set_text("now")
			elseif time_difference >= 60 and time_difference < 3600 then
				local time_in_minutes = math.floor(time_difference / 60)
				set_text(time_in_minutes .. "m ago")
			elseif time_difference >= 3600 and time_difference < 86400 then
				set_text(exact_time)
			elseif time_difference >= 86400 then
				set_text(exact_date_time)
				return false
            end

			collectgarbage("collect")
		end
	}

    return notifbox_timepop
end

function builder.build(n)
    local message_widget = builder.message(n.message)
    local image_widget   = builder.image(n.image)
    local actions_widget = builder.actions(n)
    local close_button   = builder.close_button(n)

    local default_message_height = actions_widget and dpi(67.5) or dpi(112.5)
    if image_widget then
        message_widget.point = {
            x = dpi(140),
            y = 0,
            width = dpi(235),
            height = default_message_height,
        }
    else
        message_widget.point = {
            x = dpi(10),
            y = 0,
            width = dpi(350),
            height = default_message_height
        }
    end

    local show_expand_button = image_widget ~= nil
        or message_widget:get_height_for_width_at_dpi(message_widget.point.width,
            beautiful.xresources.get_dpi()) > default_message_height

    local notifbox
    local expand_button = show_expand_button and button {
        point = { x = dpi(365), y = 0, width = dpi(25), height = dpi(25), },
        width = dpi(25),
        height = dpi(25),
        on_release = function(_, _, _, _, b)
            if b == 1 then
                if notifbox.expanded then
                    notifbox:collapse()
                else
                    notifbox:expand()
                end
                notifbox.expanded = not notifbox.expanded
            end
        end,
        widget = {
            widget = wibox.widget.textbox,
            font = beautiful.icon_font .. "18",
            halign = "center",
            valign = "center",
            text = "\u{e5cf}",
        }
    } or nil

    notifbox = wibox.widget {
        layout = wibox.layout.fixed.vertical,
        forced_width = dpi(400),
        fill_space = true,
        spacing = dpi(4),
        {
            widget = wibox.container.margin,
            top = dpi(4),
            left = dpi(4),
            right = dpi(8),
            {
                layout = wibox.layout.align.horizontal,
                {
                    layout = wibox.layout.fixed.horizontal,
                    fill_space = true,
                    spacing = dpi(8),
                    builder.app_icon(n.app_icon),
                    builder.title(n.title),
                },
                nil,
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(8),
                    builder.app_name(n.app_name),
                    close_button,
                }
            }
        },
        {
            id = "content_constraint",
            widget = wibox.container.constraint,
            strategy = "exact",
            height = dpi(67.5),
            {
                id = "content_layout",
                layout = wibox.layout.manual,
                spacing = dpi(10),
                image_widget,
                message_widget,
                expand_button,
            }
        },
        actions_widget,
    }

    notifbox:connect_signal("mouse::enter", function()
        -- fade out the progressbar
        close_button:fade_out()
    end)

    function notifbox:expand()
        if not expand_button then return end

        local content = self:get_children_by_id("content_layout")[1]
        local constraint = self:get_children_by_id("content_constraint")[1]

        -- get the appropriate(spelling?) height for the message
        local new_message_height = message_widget:get_height_for_width_at_dpi(dpi(350),
            beautiful.xresources.get_dpi())

        if image_widget then
            constraint:set_height(new_message_height + dpi(180))
            content:move(1, { x = dpi(40), y = 0, width = dpi(320), height = dpi(180) })
            content:move(2, { x = dpi(15), y = dpi(180), width = dpi(350), height = new_message_height })
        else
            constraint:set_height(math.max(dpi(67.5), new_message_height))
            content:move(1, { x = dpi(10), y = 0, width = dpi(350), height = new_message_height })
        end

        expand_button:get_widget():set_text("\u{e5ce}")

        self:emit_signal("expand")
    end

    function notifbox:collapse()
        if not expand_button then return end

        local content = self:get_children_by_id("content_layout")[1]
        local constraint = self:get_children_by_id("content_constraint")[1]
        if image_widget then
            content:move(1, { x = dpi(10), y = 0, width = dpi(120), height = dpi(67.5) })
            content:move(2, { x = dpi(140), y = 0, width = dpi(225) })
            constraint:set_height(dpi(67.5))
        else
            content:move(1, { x = dpi(10), y = 0, width = dpi(350), height = default_message_height })
            constraint:set_height(dpi(67.5))
        end

        expand_button:get_widget():set_text("\u{e5cf}")

        self:emit_signal("collapse")
    end

    notifbox.expanded = false

    return notifbox
end

return builder

