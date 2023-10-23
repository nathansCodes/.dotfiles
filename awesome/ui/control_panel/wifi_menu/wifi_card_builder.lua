local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local popup = require("ui.widgets.popup")

local builder = {}

function builder.icon(strength, password_needed)
    return wibox.widget {
        layout = wibox.layout.align.horizontal,
        resize = true,
        expand = "none",
        nil,
		{
			id = 'icon',
			text =    tonumber(strength) >= 75 and ( password_needed and '\u{f532}' or '\u{eb1a}' )
                   or tonumber(strength) >= 50 and ( password_needed and '\u{f58d}' or '\u{ebe1}' )
                   or tonumber(strength) >= 25 and ( password_needed and '\u{f58e}' or '\u{ebd6}' )
                   or                              ( password_needed and '\u{f58f}' or '\u{ebe4}' ),
            forced_width = dpi(32),
			widget = wibox.widget.textbox,
            font = beautiful.icon_font .. "24",
            halign = "left",
            valign = "center",
		},
        nil,
    }
end

function builder.connected_text(connected)
    return wibox.widget {
        widget = wibox.widget.textbox,
        font = "Inter Regular 11",
        valign = "center",
        text = connected and "connected" or "",
    }
end

local function try_connect(ssid)
    local passwd_request = popup.create_popup {
        type = "input",
        title = "Connect to " .. ssid,
        message = "Wi-Fi network \""..ssid.."\" requires authentication. "
                  .."Please enter password to connect to the network",
        confirm_button_text = "Connect",
        hide_input = true,
        on_confirm = function(password)
            awful.spawn.easy_async("nmcli d wifi connect \""
                                    .. ssid .. "\" password " .. password, function(_, stderr, _, exitcode)
                if exitcode ~= 0 then
                    naughty.notify {
                        title = "Could not connect to \""..ssid.."\"",
                        message = "Failed connecting to Wi-Fi network with ssid \""
                                  ..ssid.."\".\n"
                                  .."Reason:\n"..stderr,
                        appname = "System",
                    }
                end
            end)
        end,
    }
    passwd_request:start()
end

function builder.build_wifi_card(ssid, strength, is_connected, password_needed)

    local ssid_text = wibox.widget {
        id = "ssid",
        widget = wibox.widget.textbox,
        text = ssid,
        font = "Inter Bold 14",
        valign = "center",
    }

    local expand_button = wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.icon_font .. "24",
        valign = "center",
        text = '\u{e5cc}',
    }

    local lower_section = wibox.widget {
        widget = wibox.container.background,
        visible = false,
        bg = is_connected and beautiful.bg_normal
        or beautiful.highlight_med .. beautiful.semi_transparent,
        fg = is_connected and beautiful.green or nil,
        forced_height = dpi(35),
        shape = gears.shape.rounded_rect,
        buttons = {
            awful.button({}, 1, function()
                if is_connected then return end
                if not password_needed then
                    awful.spawn("nmcli d wifi connect '" .. ssid .. "'")
                else
                    try_connect(ssid)
                end
            end),
        },
        {
            widget = wibox.container.place,
            {
                widget = wibox.widget.textbox,
                font   = 'Inter Regular 11',
                text   = is_connected and "Already connected" or "Connect",
            }
        }
    }

    strength = tonumber(strength)

    local widget = wibox.widget {
        widget = wibox.container.margin,
        left = dpi(8),
        right = dpi(8),
        {
            id = "background",
            widget = wibox.container.background,
            bg = is_connected and beautiful.green .. beautiful.semi_transparent
                              or beautiful.bg_focus .. beautiful.transparent,
            fg = is_connected and beautiful.bg_normal
                              or tonumber(strength) >= 75 and beautiful.success
                              or tonumber(strength) >= 50 and beautiful.warn
                              or tonumber(strength) >= 25 and beautiful.warn2
                              or                              beautiful.error,
            shape = gears.shape.rounded_rect,
            {
                widget = wibox.container.margin,
                margins = dpi(8),
                {
                    layout = wibox.layout.fixed.vertical,
                    {
                        layout = wibox.layout.align.horizontal,
                        expand = "inside",
                        spacing = dpi(4),
                        buttons = {
                            awful.button({}, 1, function()
                                if lower_section.visible then
                                    expand_button:set_text("\u{e5cc}")
                                    lower_section.visible = false
                                else
                                    expand_button:set_text("\u{e5cf}")
                                    lower_section.visible = true
                                end
                            end),
                        },
                        {
                            id = "left",
                            layout = wibox.layout.fixed.horizontal,
                            builder.icon(strength, password_needed),
                            ssid_text,
                        },
                        nil,
                        {
                            id = "right",
                            layout = wibox.layout.fixed.horizontal,
                            builder.connected_text(is_connected),
                            expand_button,
                        },
                    },
                    lower_section,
                }
            }
        },
    }

    function widget:update(new_ssid, new_strength, connected, new_password_needed)
        local left = self:get_children_by_id("left")[1]
        local right = self:get_children_by_id("right")[1]
        local bg = self:get_children_by_id("background")[1]

        new_strength = tonumber(new_strength)

        bg.bg = connected and beautiful.green .. beautiful.semi_transparent
                          or beautiful.bg_focus .. beautiful.transparent
        bg.fg = connected and beautiful.bg_normal
                          or new_strength >= 75 and beautiful.success
                          or new_strength >= 50 and beautiful.warn
                          or new_strength >= 25 and beautiful.warn2
                          or                        beautiful.error

        left:reset(left)
        left:insert(1, builder.icon(new_strength, new_password_needed))
        ssid_text:set_text(new_ssid)
        left:insert(2, ssid_text)

        right.children[1] = builder.connected_text(connected)

        lower_section.buttons = {
            awful.button({}, 1, function()
                if connected then return end
                if not new_password_needed then
                    awful.spawn("nmcli d wifi connect '" .. new_ssid .. "'")
                else
                    try_connect(new_ssid)
                end
            end),
        }
    end

    return widget
end

return builder
