local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local builder = {}

function builder.create_input_popup(title, message, inputbox_placeholder, confirm_button_text, on_confirm, hide_input)

    local inputbox = wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.font .. " Regular 14",
        text = inputbox_placeholder,
    }

    local close_button = wibox.widget {
        widget = wibox.container.background,
        shape = gears.shape.circle,
        forced_width = dpi(24),
        forced_height = dpi(24),
        bg = beautiful.red,
    }

    local confirm_button = wibox.widget {
        widget = wibox.container.background,
        shape = gears.shape.rounded_rect,
        forced_height = dpi(35),
        bg = beautiful.highlight_med,
        fg = beautiful.green,
        {
            widget = wibox.widget.textbox,
            font = beautiful.font .. " Regular 14",
            halign = "center",
            valign = "center",
            text = confirm_button_text or "Confirm",
        }
    }

    local box = awful.popup {
        minimum_width = dpi(300),
        minimum_height = dpi(250),
        maximum_width = dpi(500),
        maximum_height = dpi(450),

        screen = 1,
        placement = awful.placement.centered,
        bg = beautiful.bg_normal,
        shape = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 20)
        end,
        ontop = true,
        visible = false,

        widget = wibox.widget {
            widget = wibox.container.margin,
            margins = dpi(8),
            {
                layout = wibox.layout.fixed.vertical,
                fill_space = true,
                spacing = dpi(6),
                {
                    layout = wibox.layout.fixed.horizontal,
                    fill_space = true,
                    {
                        widget = wibox.container.background,
                        fg = beautiful.second_accent,
                        {
                            widget = wibox.widget.textbox,
                            font = beautiful.font .. " Bold 16",
                            text = title,
                        }
                    },
                    {
                        widget = wibox.container.place,
                        halign = "right",
                        valign = "top",
                        close_button,
                    }
                },
                {
                    widget = wibox.widget.textbox,
                    font = beautiful.font .. " Regular 12",
                    text = message,
                },
                {
                    widget = wibox.container.place,
                    fill_horizontal = false,
                    content_fill_horizontal = true,
                    valign = "bottom",
                    {
                        layout = wibox.layout.fixed.vertical,
                        spacing = dpi(6),
                        {
                            widget = wibox.container.background,
                            bg = beautiful.highlight_med,
                            shape = gears.shape.rounded_rect,
                            forced_height = dpi(35),
                            {
                                widget = wibox.container.margin,
                                left = dpi(8),
                                right = dpi(8),
                                inputbox,
                            },
                        },
                        confirm_button,
                    }
                }
            }
        }
    }

    local keygrabber

    local input = ""

    local remove_placeholder = true

    function box:stop()
        awful.keygrabber.stop(keygrabber)
        box.visible = false
    end

    function box:confirm()
        box:stop()
        if on_confirm ~= nil then
            on_confirm(input)
        end
    end

    function box:start()
        keygrabber = awful.keygrabber.run(function(_, key, event)
            if event == "release" then return end

            if key == "Escape" then box:stop() end

            if key == "Return" then box:confirm() end

            if     key == "Caps_Lock_L"
                or key == "Caps_Lock_R"
                or key == "Control_L"
                or key == "Control_R"
                or key == "Super_L"
                or key == "Super_R"
                or key == "Shift_L"
                or key == "Shift_R"
                or key == "Alt_L"
                or key == "Alt_R"
                or key == "Tab"
                or key == "Tab" then return end

            if key == "BackSpace" then
                input = string.sub(input, 1, -2)
                if input == "" then
                    inputbox:set_text(inputbox_placeholder)
                    remove_placeholder = true
                else
                    inputbox:set_text(string.sub(inputbox.text, 1, -2))
                end
                return
            end

            if hide_input then
                if remove_placeholder then
                    inputbox:set_text("")
                    remove_placeholder = false
                end
                inputbox:set_text(inputbox.text .. "*")
            else
                if remove_placeholder then
                    inputbox:set_text("")
                    remove_placeholder = false
                end
                inputbox:set_text(inputbox.text .. key)
            end

            input = input .. key
        end)
        self.visible = true
    end

    confirm_button:connect_signal("button::press", function(_, _, _, button)
        if button ~= 1 then return end
        box:confirm()
    end)

    close_button:connect_signal("button::press", function(_, _, _, button)
        if button ~= 1 then return end
        box:stop()
    end)

    close_button:connect_signal("mouse::enter",  function()
        mouse.current_wibox.cursor = "hand1"
    end)

    close_button:connect_signal("mouse::leave",  function()
        mouse.current_wibox.cursor = "left_ptr"
    end)


    return box
end

local M = {}

function M.create_popup(args)
    if args.type == "input" then
        return builder.create_input_popup(args.title, args.message, args.inputbox_placeholder,
                                          args.confirm_button_text, args.on_confirm, args.hide_input)
    end
end

return M
