local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local Gio = require("lgi").Gio
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local iconTheme = require("lgi").require("Gtk", "3.0").IconTheme.get_default()
local helpers = require("helpers")
local sidebar = require("ui.components.launcher.sidebar")
local button = require("ui.widget.button")

--- Number of apps to be shown at once
local num_apps = 7

local horizontal_separator = wibox.widget {
    orientation = "horizontal",
    forced_height = dpi(1.5),
    forced_width = dpi(1.5),
    span_ratio = 0.95,
    widget = wibox.widget.separator,
    color = beautiful.text,
    border_color = beautiful.text,
    opacity = 0.55
}

local launcherdisplay = wibox {
    type = "notification",
    width = dpi(530),
    height = dpi(650),
    bg = beautiful.base,
    ontop = true,
    visible = false,
    border_width = dpi(3),
    border_color = beautiful.base,
    shape = helpers.ui.rrect(20)
}

local prompt = wibox.widget {
    widget = wibox.widget.textbox,
    valign = "center",
    font = beautiful.font .. "13"
}

local entries = wibox.widget {
    homogeneous = false,
    expand = true,
    forced_num_cols = 1,
    layout = wibox.layout.grid
}

launcherdisplay:setup {
    layout = wibox.layout.fixed.horizontal,
    sidebar,
    {
        {
            {
                {
                    {
                        {
                            prompt,
                            widget = wibox.container.margin,
                            margins = dpi(6),
                            forced_width = dpi(410)
                        },
                        bg = beautiful.overlay,
                        widget = wibox.container.background,
                        shape = helpers.ui.rrect(5),

                    },
                    widget = wibox.container.margin,
                    margins = dpi(10)
                },
                {

                    {
                        horizontal_separator,
                        entries,
                        layout = wibox.layout.fixed.vertical
                    },
                    margins = dpi(10),
                    widget = wibox.container.margin
                },
                layout = wibox.layout.fixed.vertical
            },
            widget = wibox.container.margin,
            margins = dpi(15),
        },
        widget = wibox.container.background,
        bg = beautiful.surface,
        shape = helpers.ui.rrect(14),
    },
}
-- Functions

local function next()
    if entryindex ~= #filtered then
        entries:get_widgets_at(entryindex, 1)[1]:unhover()
        entries:get_widgets_at(entryindex + 1, 1)[1]:hover()
        entryindex = entryindex + 1
        if entryindex > startindex + (num_apps - 1) then
            entries:get_widgets_at(entryindex - num_apps, 1)[1].visible = false
            entries:get_widgets_at(entryindex, 1)[1].visible = true
            startindex = startindex + 1
        end
    end
    move = true
end

local function back()
    if entryindex ~= 1 then
        entries:get_widgets_at(entryindex, 1)[1]:unhover()
        entries:get_widgets_at(entryindex - 1, 1)[1]:hover()
        entryindex = entryindex - 1
        if entryindex < startindex then
            entries:get_widgets_at(entryindex + num_apps, 1)[1].visible = false
            entries:get_widgets_at(entryindex, 1)[1].visible = true
            startindex = startindex - 1
        end
    end
    move = true
end

local function gen()
    local entries = {}
    for _, entry in ipairs(Gio.AppInfo.get_all()) do
        if entry:should_show() then
            local name = entry:get_name():gsub("&", "&amp;"):gsub("<", "&lt;"):gsub("'", "&#39;")
            local icon = entry:get_icon()
            local path
            if icon then
                path = icon:to_string()
                if not path:find("/") then
                    local icon_info = iconTheme:lookup_icon(path, dpi(48), 0)
                    local p = icon_info and icon_info:get_filename()
                    path = p
                end
            end
            local description = entry:get_description()
            table.insert(
                entries,
                { name = name, appinfo = entry, description = description, icon = path or "" }
            )

            -- table.insert(, description
            --   entries,
            --   { name = name, appinfo = entry }
            -- )
        end
    end
    return entries
end

local function close()
    awful.keygrabber.stop()
    launcherdisplay.visible = false
    awesome.emit_signal("launcher::closed")
end

local function filter(cmd)
    filtered = {}
    regfiltered = {}

    -- Filter entries

    for _, entry in ipairs(unfiltered) do
        if entry.name:lower():sub(1, cmd:len()) == cmd:lower() then
            table.insert(filtered, entry)
        elseif entry.name:lower():match(cmd:lower()) then
            table.insert(regfiltered, entry)
        end
    end

    -- Sort entries

    table.sort(filtered, function(a, b) return a.name:lower() < b.name:lower() end)
    table.sort(regfiltered, function(a, b) return a.name:lower() < b.name:lower() end)

    -- Merge entries

    for i = 1, #regfiltered do
        filtered[#filtered + 1] = regfiltered[i]
    end

    -- Clear entries

    entries:reset()

    -- Fix position

    entryindex, startindex = 1, 1

    -- Add filtered entries

    for i, entry in ipairs(filtered) do
        local widget = button {
            on_release = function(_, _, _, _, b)
                if b == 1 then
                    if entryindex == i then
                        local entry = filtered[entryindex]
                        entry.appinfo:launch()
                        close()
                    else
                        entries:get_widgets_at(entryindex, 1)[1]:unhover()
                        entryindex = i
                        entries:get_widgets_at(entryindex, 1)[1]:hover()
                    end
                elseif b == 3 then
                    close()
                elseif b == 4 then
                    back()
                elseif b == 5 then
                    next()
                end
            end,
            on_mouse_enter = function()
                entries:get_widgets_at(entryindex, 1)[1]:unhover()
                entryindex = i
            end,
            shape = helpers.ui.rrect(5),
            widget = wibox.widget {
                widget = wibox.container.margin,
                margins = dpi(12),
                forced_height = dpi(77),
                forced_width = dpi(400),
                {
                    layout = wibox.layout.fixed.horizontal,
                    {
                        widget = wibox.widget.imagebox,
                        image = entry.icon,
                        clip_shape = function(cr, width, height)
                            gears.shape.rounded_rect(cr, width, height, 10)
                        end,
                        forced_height = dpi(50),
                        forced_width = dpi(50),
                        valign = "center",
                    },
                    {
                        widget = wibox.container.margin,
                        left = dpi(15),
                        bottom = dpi(5),
                        forced_height = dpi(55),
                        {
                            layout = wibox.layout.fixed.vertical,
                            {
                                widget = wibox.widget.textbox,
                                markup = "<span color='" ..
                                        beautiful.accent .. "' font='"..beautiful.mono_font.."15 bold'>" .. entry.name .. "</span>",
                                forced_height = dpi(30),
                                valign = "center",
                            },
                            {
                                widget = wibox.widget.textbox,
                                markup = "<span color='" ..
                                        beautiful.text .. "' font='"..beautiful.mono_font.."13'>" .. (entry.description or "") .. "</span>",
                                valign = "center",
                            },
                        },
                    },
                },
            },
        }

        if startindex <= i and i <= startindex + (num_apps - 1) then
            widget.visible = true
        else
            widget.visible = false
        end

        entries:add(widget)

        if i == entryindex then
            widget:hover()
        end
    end

    collectgarbage("collect")
end

local function open()
    -- Reset variables

    startindex, entryindex, move = 1, 1, false

    -- Get entries

    unfiltered = gen()
    filter("")

    -- Prompt

    awful.prompt.run {
        prompt = "<span font='"..beautiful.icon_font.." Bold 14'>\u{e8b6}</span>",
        textbox = prompt,
        fg_cursor = beautiful.text,
        done_callback = function()
            launcherdisplay.visible = false
            awesome.emit_signal("launcher::closed")
        end,
        changed_callback = function(cmd)
            if move == false then
                filter(cmd)
            else
                move = false
            end
        end,
        exe_callback = function(cmd)
            local entry = filtered[entryindex]
            if entry then
                entry.appinfo:launch()
            else
                awful.spawn.with_shell(cmd)
            end
        end,
        keypressed_callback = function(_, key)
            if key == "Down" then
                next()
            elseif key == "Up" then
                back()
            end
        end
    }
end


awful.mouse.append_client_mousebinding(awful.button({ "Any" }, 1, close))

awful.mouse.append_client_mousebinding(awful.button({ "Any" }, 3, close))

awful.mouse.append_global_mousebinding(awful.button({ "Any" }, 1, close))

awful.mouse.append_global_mousebinding(awful.button({ "Any" }, 3, close))

tag.connect_signal("property::selected", close)


awesome.connect_signal("launcher::open", function()
    launcherdisplay.visible = not launcherdisplay.visible

    awful.placement.bottom(
        launcherdisplay,
        {
            parent = awful.screen.focused(),
            margins = { bottom = dpi(80) }
        }
    )

    open()
end)

awesome.connect_signal("launcher::toggle", function()
    if launcherdisplay.visible then
        close()
    else
        awful.placement.bottom(
            launcherdisplay,
            {
                parent = awful.screen.focused(),
                margins = { bottom = dpi(80) }
            }
        )

        open()
    end
    launcherdisplay.visible = not launcherdisplay.visible
end)
