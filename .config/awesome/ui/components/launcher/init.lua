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

local fzy = require("fzy")

local capi = { awesome = awesome, tag = tag }

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
    type = "normal",
    width = dpi(530),
    height = dpi(650),
    bg = beautiful.base,
    ontop = true,
    visible = false,
    border_width = dpi(3),
    border_color = beautiful.base,
    shape = helpers.ui.rrect(14)
}

local prompt = wibox.widget {
    widget = wibox.widget.textbox,
    valign = "center",
    font = beautiful.font .. "13"
}

local entry_cache = {}

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
        shape = helpers.ui.rrect(10),
    },
}
-- Functions

local function next(mouse_scroll)
    if entryindex <= #filtered - num_apps then
        entries:get_widgets_at(entryindex, 1)[1]:unhover()
        entryindex = entryindex + 1
        entries:get_widgets_at(entryindex, 1)[1]:hover()
        if mouse_scroll or entryindex - num_apps == startindex then
            entries:get_widgets_at(startindex, 1)[1].visible = false
            entries:get_widgets_at(startindex + num_apps, 1)[1].visible = true
            startindex = startindex + 1
        end
    end
    move = true
end

local function back(mouse_scroll)
    if entryindex ~= 1 then
        if startindex > 1 and mouse_scroll or entryindex == startindex then
            startindex = startindex - 1
            entries:get_widgets_at(startindex + num_apps, 1)[1].visible = false
            entries:get_widgets_at(startindex, 1)[1].visible = true
        end
        entries:get_widgets_at(entryindex, 1)[1]:unhover()
        entryindex = entryindex - 1
        entries:get_widgets_at(entryindex, 1)[1]:hover()
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
            entries[name] = {
                name = name,
                appinfo = entry,
                description = description,
                icon = path or ""
            }
        end
    end
    return entries
end

local function close()
    if not launcherdisplay.visible then return end
    awful.screen.focused().launcher_visible = false
    launcherdisplay.visible = false
    awful.keygrabber.stop()
    capi.awesome.emit_signal("launcher::closed")
end

local function filter(cmd)
    filtered = {}

    -- Filter entries

    local haystacks = gears.table.keys(unfiltered)
    local result = fzy.filter(cmd, haystacks)

    -- Fix position

    entryindex, startindex = 1, 1

    -- Add filtered entries

    for i, score in ipairs(result) do
        local entry = unfiltered[haystacks[score[1]]]
        table.insert(filtered, entry)

        local widget = entries.children[i] ~= nil and entries.children[i] or button {
            hover_on_mouse_enter = false,
            bg = beautiful.surface,
            hover_color = beautiful.highlight_low,
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
                    back(true)
                elseif b == 5 then
                    next(true)
                end
            end,
            on_mouse_enter = function(self)
                entries:get_widgets_at(entryindex, 1)[1]:unhover()
                self:hover()
                entryindex = i
            end,
            on_mouse_leave = function(self)
                self:unhover()
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
                        id = "icon",
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
                                id = "name",
                                widget = wibox.widget.textbox,
                                font = beautiful.mono_font.."15 bold",
                                markup = helpers.ui.colorize_text(entry.name,
                                    beautiful.accent),
                                forced_height = dpi(30),
                                valign = "center",
                            },
                            {
                                id = "description",
                                widget = wibox.widget.textbox,
                                font = beautiful.mono_font.."13",
                                markup = entry.description or "",
                                valign = "center",
                            },
                        },
                    },
                },
            },
        }

        -- show the widget if it's been matched and it's in view
        if startindex <= i and i <= startindex + (num_apps - 1) then
            widget.visible = true
        else
            widget.visible = false
        end

        -- add the widget if it wasn't already there, otherwise just modify it
        if entries.children[i] == nil then
            entries:add(widget)
        else
            local icon = widget:get_children_by_id("icon")[1]
            local name = widget:get_children_by_id("name")[1]
            local description = widget:get_children_by_id("description")[1]
            icon:set_image(entry.icon)
            name:set_markup(helpers.ui.colorize_text(entry.name, beautiful.accent))
            description:set_text(entry.description or "")
        end

        -- hover if hovered, otherwise not
        if entryindex == i then
            widget:hover()
        else
            widget:unhover()
        end
    end

    -- hide the rest
    for i = #result + 1, #entries.children do
        entries.children[i].visible = false
    end

    collectgarbage("collect")
end

local function open()
    awful.placement.bottom(
        launcherdisplay,
        {
            parent = awful.screen.focused(),
            margins = { bottom = dpi(80) }
        }
    )

    -- Reset variables

    startindex, entryindex, move = 1, 1, false

    -- Get entries

    unfiltered = gen()
    filter("")

    -- Prompt

    awful.prompt.run {
        prompt = "<span font='"..beautiful.icon_font.." Bold 14'>\u{e8b6}</span>",
        textbox = prompt,
        bg_cursor = beautiful.overlay,
        done_callback = close,
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
                next(false)
            elseif key == "Up" then
                back(false)

            end
        end
    }

    launcherdisplay.visible = true
    awful.screen.focused().launcher_visible = true
    capi.awesome.emit_signal("launcher::opened")
end


awful.mouse.append_client_mousebinding(awful.button({ "Any" }, 1, close))

awful.mouse.append_client_mousebinding(awful.button({ "Any" }, 3, close))

awful.mouse.append_global_mousebinding(awful.button({ "Any" }, 1, close))

awful.mouse.append_global_mousebinding(awful.button({ "Any" }, 3, close))

capi.tag.connect_signal("property::selected", close)


capi.awesome.connect_signal("launcher::open", open)
capi.awesome.connect_signal("launcher::close", close)

function launcherdisplay:toggle()
    if self.visible then
        close()
    else
        open()
    end
end

return launcherdisplay
