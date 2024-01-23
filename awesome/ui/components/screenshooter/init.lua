local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local root = require("root")
local cairo = require("lgi").cairo

local helpers = require("helpers")
local button = require("ui.widget.button")

local root_width, root_height = root.size()

local full_screenshot = wibox.widget {
    widget = wibox.widget.imagebox,
    opacity = 0,
    forced_width = root_width,
    forced_height = root_height,
    resize = false,
}

local selection = {
    x = -1,
    y = -1,
    width = 0,
    height = 0,
    client = nil,
}

local capi = {
    mouse = mouse,
    screen = screen,
    awesome = awesome,
    mousegrabber = mousegrabber,
}

-- what shows before selecting
local preselection = wibox.widget {
    widget = wibox.container.margin,
    visible = false,
    {
        widget = wibox.container.place,
        {
            widget = wibox.container.background,
            shape = helpers.ui.rrect(20),
            bg = beautiful.surface .. "e8",
            fg = beautiful.text,
            {
                widget = wibox.container.margin,
                margins = dpi(10),
                {
                    layout = wibox.layout.fixed.vertical,
                    {
                        layout = wibox.layout.fixed.horizontal,
                        spacing = dpi(5),
                        {
                            widget = wibox.widget.textbox,
                            font = beautiful.icon_font .. "Bold 26",
                            halign = "left",
                            text = "\u{f7d2}"
                        },
                        {
                            widget = wibox.widget.textbox,
                            font = beautiful.font .. "Regular 16",
                            text = "Select an area to screenshot"
                        },
                    },
                    {
                        layout = wibox.layout.fixed.horizontal,
                        spacing = dpi(5),
                        {
                            widget = wibox.widget.textbox,
                            font = beautiful.icon_font .. "Bold 26",
                            halign = "left",
                            text = "\u{f727}",
                        },
                        {
                            widget = wibox.widget.textbox,
                            font = beautiful.font .. "Regular 16",
                            markup = "Hold <b>Shift</b> to select a window"
                        },
                    },
                    {
                        layout = wibox.layout.fixed.horizontal,
                        spacing = dpi(5),
                        {
                            widget = wibox.widget.textbox,
                            font = beautiful.icon_font .. "Bold 26",
                            halign = "left",
                            text = "\u{ec08}",
                        },
                        {
                            widget = wibox.widget.textbox,
                            font = beautiful.font .. "Regular 16",
                            markup = "Hold <b>Control</b> to select a screen"
                        },
                    }
                },
            }
        }
    }
}

local selection_dimensions = wibox.widget {
    widget = wibox.widget.textbox,
    font = beautiful.font .. "SemiBold 9",
    -- first time i ever used and will use this
    line_spacing_factor = 0.8,
    valign = "bottom",
    halign = "center",
}

local save_button = button {
    bg = beautiful.overlay,
    fg = beautiful.accent,
    shape = helpers.ui.rrect(10),
    width = dpi(50),
    height = dpi(50),
    animate = false,
    widget = wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.icon_font .. "Bold 24",
        text = "\u{e161}",
        valign = "center",
        halign = "center",
    },
}

local copy_button = button {
    bg = beautiful.overlay,
    fg = beautiful.accent,
    shape = helpers.ui.rrect(10),
    width = dpi(50),
    height = dpi(50),
    animate = false,
    widget = wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.icon_font .. "Bold 24",
        text = "\u{e14d}",
        valign = "center",
        halign = "center",
    },
}

local sidebar_width = dpi(80)
local sidebar_height = dpi(300)
local sidebar_selection_spacing = dpi(15)

local sidebar = wibox.widget {
    point = { x = -1, y = -1, width = 0, height = 0 },
    widget = wibox.container.margin,
    left = 0,
    top = 0,
    right = 0,
    bottom = 0,
    visible = false,
    {
        widget = wibox.container.background,
        bg = beautiful.surface .. "e8",
        shape = helpers.ui.rrect(20),
        forced_width = sidebar_width,
        forced_height = sidebar_height,
        {
            widget = wibox.container.margin,
            margins = dpi(10),
            {
                layout = wibox.layout.fixed.vertical,
                spacing = dpi(5),
                fill_space = true,
                save_button,
                copy_button,
                {
                    widget = wibox.container.margin,
                    margins = dpi(10),
                    selection_dimensions,
                }
            }
        }
    }
}

local selrect_image = wibox.widget {
    widget = wibox.container.margin,
    wibox.widget.base.make_widget(full_screenshot)
}

local selection_rect = wibox.widget {
    point = { x = -1, y = -1, width = 0, height = 0 },
    widget = wibox.container.background,
    border_width = dpi(2),
    border_color = beautiful.text,
    selrect_image
}

local function update_selrect_image()
    selrect_image:set_left(-selection.x)
    selrect_image:set_top(-selection.y)
end

local selection_container = wibox.widget {
    layout = wibox.layout.manual,
    forced_width = root_width,
    forced_height = root_height,
    right = root_width,
    bottom = root_height,
    selection_rect,
    sidebar,
}

local selection_bg = wibox.widget {
    widget = wibox.container.background,
    bg = "#00000055",
    {
        layout = wibox.layout.stack,
        selection_container,
        preselection,
    }
}


local screenshot_overlay = awful.popup {
    type = "utility",

    width = root_width,
    height = root_height,

    visible = false,
    ontop = true,

    widget = {
        layout = wibox.layout.stack,
        full_screenshot,
        selection_bg,
    }
}

-- update overlay size when screen is added
capi.screen.connect_signal("added", function()
    root_width, root_height = root.size()
    selection_container:set_forced_width(root_width)
    selection_container:set_forced_height(root_height)
    full_screenshot:set_forced_width(root_width)
    full_screenshot:set_forced_height(root_height)
end)

local sidebar_hovered = false

sidebar:connect_signal("mouse::enter", function() sidebar_hovered = true end)
sidebar:connect_signal("mouse::leave", function() sidebar_hovered = false end)

local mode = "rect"

-- update the selection based on cursor position
local function update_selection(cursor, initial)
    if sidebar_hovered then return end
    -- show the sidebar
    sidebar.visible = true
    -- hide pre selection screen
    preselection.visible = false

    local x = selection.x
    local y = selection.y
    local width = selection.width
    local height = selection.height

    if x == -1 or initial == true then
        x = cursor.x
        width = 0
    elseif cursor.x < x then
        x = cursor.x
        width = selection.x + selection.width - cursor.x
    else
        width = cursor.x - selection.x
        width = width == 0 and selection.width or width
    end

    if y == -1 or initial == true then
        y = cursor.y
        height = 0
    elseif cursor.y < y then
        y = cursor.y
        height = selection.y + selection.height - cursor.y
    else
        height = cursor.y - selection.y
        height = height == 0 and selection.height or height
    end

    selection_container:move(1, {
        x = x,
        y = y,
        width = width,
        height = height,
    })

    -- set the selrect's border radius based on the size
    local border_radius = math.min(math.max(3, math.min(width+height) * 0.025), 20)
    selection_rect.border_radius = dpi(border_radius)
    selection_rect:set_shape(helpers.ui.rrect(border_radius))

    local sidebar_x = x - sidebar_width - sidebar_selection_spacing
    local sidebar_y = y + sidebar_height > root_height
        and root_height - sidebar_height
        or y

    if sidebar_x < 0 or sidebar_x < capi.mouse.screen.geometry.x then
        sidebar_x = x + width + sidebar_selection_spacing
    end

    if mode == "screen" or sidebar_x + sidebar_selection_spacing + sidebar_width > root_width then
        sidebar_x = x + width - sidebar_selection_spacing - sidebar_width
        sidebar_y = sidebar_y + sidebar_selection_spacing
    end

    selection_container:move(2, {
        x = sidebar_x,
        y = sidebar_y,
        width = sidebar_width,
        height = sidebar_height,
    })

    selection_dimensions:set_text(x.." "
           ..y.."\n"
           ..width.." "
           ..height)

    -- update the selection
    selection.x = x
    selection.y = y
    selection.width = width
    selection.height = height

    update_selrect_image()
end

local function set_selection(sel)
    -- show the sidebar
    sidebar.visible = true
    -- hide the preselection screen
    preselection.visible = false

    if sel.client ~= nil then
        sel.x = sel.client.x
        sel.y = sel.client.y
        sel.width = sel.client.width
        sel.height = sel.client.height
    end

    selection_container:move(1, {
        x = sel.x,
        y = sel.y,
        width = sel.width,
        height = sel.height,
    })

    -- set the selrect's border radius based on the size
    local border_radius = math.min(math.max(3, math.min(sel.width + sel.height) * 0.025), 20)
    selection_rect.border_radius = dpi(border_radius)
    selection_rect:set_shape(helpers.ui.rrect(border_radius))

    local sidebar_x = sel.x - sidebar_width - sidebar_selection_spacing
    local sidebar_y = sel.y + sidebar_height > root_height
        and root_height - sidebar_height
        or sel.y

    if sidebar_x < 0 or sidebar_x < capi.mouse.screen.geometry.x then
        sidebar_x = sel.x + sel.width + sidebar_selection_spacing
    end

    if mode == "screen" or sidebar_x + sidebar_selection_spacing + sidebar_width > root_width then
        sidebar_x = sel.x + sel.width - sidebar_selection_spacing - sidebar_width
        sidebar_y = sidebar_y + sidebar_selection_spacing
    end

    selection_container:move(2, {
        x = sidebar_x,
        y = sidebar_y,
        width = sidebar_width,
        height = sidebar_height,
    })

    selection_dimensions:set_text(sel.x.." "
           ..sel.y.."\n"
           ..sel.width.." "
           ..sel.height)

    -- update the selection
    selection.x = sel.x
    selection.y = sel.y
    selection.width = sel.width
    selection.height = sel.height
    selection.client = sel.client

    update_selrect_image()
end

local function reset_selection()
    selection_container:move(1, {
        x = -1,
        y = -1,
        width = 0,
        height = 0,
    })

    selection_container:move(2, {
        x = -1,
        y = -1,
        width = 0,
        height = 0,
    })

    selection = {
        x = -1,
        y = -1,
        width = 0,
        height = 0,
    }
end

local function start_window_select()
    mode = "window"

    screenshot_overlay.input_passthrough = true

    local focused_object = capi.mouse.object_under_pointer()

    -- reset selection and return if nothing is focused
    if focused_object == nil then
        reset_selection()
    elseif capi.mouse.current_client ~= nil then
        set_selection { client = focused_object }
    else
        local object_geo = focused_object:geometry()

        set_selection {
            x = object_geo.x,
            y = object_geo.y,
            width = object_geo.width,
            height = object_geo.height,
        }
    end

    capi.mousegrabber.run(function()
        if mode ~= "window" then return false end

        local focused_object = capi.mouse.object_under_pointer()

        -- reset selection and return if nothing is focused
        if focused_object == nil then
            reset_selection()
        elseif capi.mouse.current_client ~= nil then
            set_selection { client = focused_object }
        else
            local object_geo = focused_object:geometry()

            set_selection {
                x = object_geo.x,
                y = object_geo.y,
                width = object_geo.width,
                height = object_geo.height,
            }
        end

        return true
    end, "cross")
end

local function stop_window_select()
    mode = "rect"
    screenshot_overlay.input_passthrough = false
    capi.mousegrabber.stop()
end

local function start_screen_select()
    mode = "screen"

    local current_screen_geo = capi.mouse.screen.geometry

    set_selection {
        x = current_screen_geo.x,
        y = current_screen_geo.y,
        width = current_screen_geo.width,
        height = current_screen_geo.height,
    }

    capi.mousegrabber.run(function()
        if mode ~= "screen" then return false end
        local current_screen_geo = capi.mouse.screen.geometry

        set_selection {
            x = current_screen_geo.x,
            y = current_screen_geo.y,
            width = current_screen_geo.width,
            height = current_screen_geo.height,
        }

        return mode == "screen"
    end, "cross")
end

local function stop_screen_select()
    mode = "rect"
    capi.mousegrabber.stop()
end

-- active keygrabber
local kg

-- take a screenshot and save it to /tmp/screenshot.png
local function create_tmp_screenshot(delay, on_save)
    local x = selection.x
    local y = selection.y
    local width = selection.width
    local height = selection.height

    reset_selection()
    selection_bg:set_visible(false)

    local shot = awful.screenshot {
        auto_save_delay = 0.1 + (delay or 0),
        file_path = "/tmp/screenshot.png",
        geometry = {
            x = x,
            y = y,
            width = width,
            height = height,
        },
    }

    shot:connect_signal("file::saved", function(self, file_path, method)
        screenshot_overlay.visible = false
        if kg ~= nil then kg:stop() end
        selection_bg:set_visible(true)

        on_save(self, file_path, method)
    end)
end

-- open file selection dialog and move screenshot
-- from /tmp/screenshot.png to selected filepath
local function save_screenshot(shot)
    local date_time = os.date("%Y-%m-%d_%H-%M-%S")
    local default_filename = os.getenv("HOME").."Pictures/Screenshots/" .. date_time .. ".png"
    local zenity_cmd = "zenity --file-selection --save --filename='" .. default_filename
            .. "' --file-filter=\"PNG File | *.png \" --title='Select a file'"

    awful.spawn.easy_async(zenity_cmd, function(filepath, _, _, exitcode)
        if exitcode ~= 0 then
            naughty.notification {
                app_name = "System",
                title = "Screenshot Aborted",
                text = "The shooting of the screen was cancelled by the user"
            }
            return
        end

        awful.spawn("mv /tmp/screenshot.png " .. filepath)

        local open_action = naughty.action { name = "Open", icon = "\u{e89e}" }
        local copy_action = naughty.action { name = "Copy", icon = "\u{e173}" }
        local delete_action = naughty.action { name = "Delete", icon = "\u{e872}" }

        open_action:connect_signal("invoked", function()
            awful.spawn.easy_async("xdg-open " .. filepath)
        end)

        copy_action:connect_signal("invoked", function()
            awful.spawn.easy_async("xclip -sel clip -t image/png " .. filepath)
        end)

        delete_action:connect_signal("invoked", function()
            awful.spawn.easy_async("rm " .. filepath, function(_, _, _, exitcode)
                if exitcode == 0 then
                    naughty.notification {
                        app_name = "System",
                        title = "Deleted Screenshot",
                        text = "Successfully deleted " .. filepath,
                    }
                else
                    naughty.notification {
                        app_name = "System",
                        title = "Screenshot",
                        text = "Failed to delete " .. filepath,
                    }
                end
            end)
        end)

        naughty.notification {
            title = "Screenshot",
            text = "Screenshot taken and saved to " .. filepath,
            image = shot.surface,
            actions = {
                open_action,
                copy_action,
                delete_action,
            }
        }
    end)
end

-- Save screenshot to file
save_button:connect_signal("button::press", function()
    create_tmp_screenshot(0, save_screenshot)
end)

-- Copy screenshot to system clipboard
copy_button:connect_signal("button::press", function()
    create_tmp_screenshot(0, function(shot)
        screenshot_overlay.visible = false
        if kg ~= nil then kg:stop() end
        selection_bg:set_visible(true)

        awful.spawn("xclip -sel clip -t image/png /tmp/screenshot.png")
        local save_action = naughty.action { name = "Save Screenshot", icon = "\u{e161}" }

        save_action:connect_signal("invoked", function() save_screenshot(shot) end)

        local notif = naughty.notification {
            app_name = "System",
            title = "Copied Screenshot",
            text = "Screenshot successfully copied to the system clipboard",
            image = shot.surface,
            actions = { save_action },
        }

        notif:connect_signal("destroyed", function() awful.spawn("rm /tmp/screenshot.png") end)
    end)
end)

kg = awful.keygrabber {
    autostart = false,
    stop_key = "Escape",
    stop_event = "release",
    keybindings = {
        awful.key {
            modifiers = { },
            key = "Shift_L",
            on_press = function() start_window_select() end,
        },
        -- no idea why but i coudldn't just put the on_release in the previous
        -- awful.key, it didn't work
        awful.key {
            -- needed, doesn't work without this mod, no idea why
            modifiers = { "Shift" },
            key = "Shift_L",
            on_release = function() stop_window_select() end,
        },
        awful.key {
            modifiers = { },
            key = "Control_L",
            on_press = function() start_screen_select() end,
        },
        -- again, same thing as above
        awful.key {
            modifiers = { "Control" },
            key = "Control_L",
            on_release = function() stop_screen_select() end,
        },
    }
}

-- abort screenshot when Escape is pressed
kg:connect_signal("stopped", function()
    mode = "rect"

    reset_selection()

    screenshot_overlay.visible = false
    screenshot_overlay.input_passthrough = false

    sidebar.visible = false

    capi.mousegrabber.stop()
end)

-- start selecting on button press
selection_container:connect_signal("button::press", function()
    -- don't select when sidebar is hovered
    if sidebar_hovered then return end
    -- only select on left-click
    if not capi.mouse.is_left_mouse_button_pressed then return end

    -- grab cursor position
    local initial_cursor_pos = capi.mouse.coords()

    -- set initial position of selection rect
    update_selection({
        x = initial_cursor_pos.x,
        y = initial_cursor_pos.y,
    }, true)

    -- update selection on mouse move
    capi.mousegrabber.run(function(coords)
        -- set selection
        update_selection {
            x = coords.x,
            y = coords.y,
        }

        -- cancel if lmb is released or escape is pressed
        return capi.mouse.is_left_mouse_button_pressed
            and screenshot_overlay.visible
    end, "cross")
end)

capi.awesome.connect_signal("screenshot::start", function()
    full_screenshot.image = nil
    full_screenshot.opacity = 0

    local full = awful.screenshot {
        file_path = "/tmp/",
        file_name = "awm-full-screenshot.png",
        geometry = {
            x = 0,
            y = 0,
            width = root_width,
            height = root_height,
        }
    }
    full:connect_signal("file::saved", function()
        full_screenshot.image = full.surface
        full_screenshot.opacity = 1

        -- show screenshot overlay and preselection screen
        screenshot_overlay.visible = true
        preselection.visible = true

        -- show preselection widget on current screen
        local focused_screen_geo = awful.screen.focused().geometry
        preselection:set_left(focused_screen_geo.x)
        preselection:set_right(root_width - focused_screen_geo.width - focused_screen_geo.x)
        preselection:set_top(focused_screen_geo.y)
        preselection:set_bottom(root_height - focused_screen_geo.height - focused_screen_geo.y)

        kg:start()
    end)
    full:save()

end)

