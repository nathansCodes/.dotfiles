local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")
local apps = require("config.apps")
local main_menu = require("ui.components.main_menu")

local capi = { awesome = awesome, client = client }

local super = "Mod4"
local alt = "Mod1"
local shift = "Shift"
local ctrl = "Control"

local lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, "
    .. "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
    .. "Ut enim ad minim veniam, "
    .. "quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."

awful.keyboard.append_global_keybindings {
    awful.key({ super, }, " ", function() capi.awesome.emit_signal("keyboard::cycle_layouts") end,
        { description = "cycle keyboard layouts", group = "awesome" }),
    awful.key({ super, }, "s", hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),
    awful.key({ super, ctrl }, "r", capi.awesome.restart,
        { description = "reload awesome", group = "awesome" }),
    awful.key({ super, shift }, "q", capi.awesome.quit,
        { description = "quit awesome", group = "awesome" }),
    awful.key({ super, shift }, "l", function() capi.awesome.emit_signal("lockscreen::lock") end,
        { description = "open file manager", group = "launcher" }),
    awful.key({ super }, "x",
        function()
            awful.prompt.run {
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end,
        { description = "lua execute prompt", group = "awesome" }),
    awful.key({ super, }, "g", function()
            naughty.notification {
                title = "Test",
                text = lorem,
                app_name = "System",
                image = beautiful.wallpaper,
                actions = {
                    naughty.action { name = "Hello", icon = "\u{e766}" },
                    naughty.action { name = "World", icon = "\u{e64c}" }
                },
            }
        end,
        { description = "test notification", group = "awesome" }),
    awful.key({ super, shift }, "g", function()
            naughty.notification {
                title = "Test",
                text = lorem,
                app_name = "System",
                actions = {
                    naughty.action { name = "Hello", icon = "\u{e766}" },
                    naughty.action { name = "World", icon = "\u{e64c}" }
                },
            }
        end,
        { description = "test notification", group = "awesome" }),
    awful.key({ super, }, "t", function() awful.spawn(apps.terminal) end,
        { description = "open a new alacritty window", group = "launcher" }),
    awful.key({ super, }, "b", function() awful.spawn(apps.web_browser) end,
        { description = "open firefox", group = "launcher" }),
    awful.key({ super, }, "e", function() awful.spawn(apps.file_manager) end,
        { description = "open file manager (thunar)", group = "launcher" }),
    awful.key {
        modifiers = { super },
        key = "r",
        on_release = function()
            capi.awesome.emit_signal("launcher::open")
        end,
        description = "run prompt",
        group = "launcher"
    },
    awful.key {
        modifiers = { super },
        key = "y",
        on_release = function()
            local themer = require("ui.theme.themer")
            local set = require("config.user_settings")
            themer.revert(function()
                set.reload()
                themer.apply()
            end)
        end,
        description = "reload theme",
        group = "theme"
    },
}

awful.keyboard.append_global_keybindings {
    awful.key({}, "Print", function()
            capi.awesome.emit_signal("screenshot::start")
        end,
        { description = "create screen selection for a screenshot", group = "screenshot" }),
    awful.key({ ctrl, }, "Print", function() awful.spawn("flameshot screen") end,
        { description = "screenshot the current screen", group = "screenshot" }),
    awful.key({ shift, }, "Print", function() awful.spawn("flameshot full") end,
        { description = "screenshot the entire desktop (all screens)", group = "screenshot" }),
    awful.key({ super, }, "Print", function() awful.spawn("flameshot config") end,
        { description = "configure flameshot", group = "screenshot" }),
}

-- Rofi scripts
awful.keyboard.append_global_keybindings {
    awful.key({ super }, " ", function() awful.util.spawn(apps.app_launcher) end,
        { description = "start rofi", group = "rofi" }),
    awful.key({ super }, "'", function() awful.util.spawn("rofi -modi emoji -show emoji -theme ~/.config/rofi/applets/emoji.rasi") end,
        { description = "run prompt", group = "rofi" }),
    awful.key({ super }, "c", function() awful.spawn.with_shell("CM_LAUNCHER=rofi clipmenu -theme ~/.config/rofi/applets/clipboard.rasi") end,
        { description = "show clipboard menu", group = "rofi" }),
    awful.key({ super }, "/", function() awful.spawn.with_shell("~/.config/rofi/scripts/calc") end,
        { description = "show clipboard menu", group = "rofi" }),
    awful.key({ super }, "o", function() awful.spawn.with_shell("rofi-mpc") end,
        { description = "show clipboard menu", group = "rofi" }),
    awful.key({ super }, "v", function() capi.awesome.emit_signal("powermenu::show") end,
        { description = "show clipboard menu", group = "rofi" }),
}

-- Tags related keybindings
awful.keyboard.append_global_keybindings {
    awful.key({ super, }, "h", awful.tag.viewprev,
        { description = "view previous", group = "tag" }),
    awful.key({ super, }, "l", awful.tag.viewnext,
        { description = "view next", group = "tag" }),
    awful.key({ super, }, "Escape", awful.tag.history.restore,
        { description = "go back", group = "tag" }),
}

-- Focus related keybindings
awful.keyboard.append_global_keybindings {
    awful.key({ alt, }, "j",
        function()
            awful.client.focus.global_bydirection("down")
        end,
        { description = "focus window below", group = "client" }
    ),
    awful.key({ alt, }, "k",
        function()
            awful.client.focus.global_bydirection("up")
        end,
        { description = "focus window above", group = "client" }
    ),
    awful.key({ alt, }, "h",
        function()
            awful.client.focus.global_bydirection("left")
        end,
        { description = "focus window to the left", group = "client" }
    ),
    awful.key({ alt, }, "l",
        function()
            awful.client.focus.global_bydirection("right")
        end,
        { description = "focus window to the right", group = "client" }
    ),
    awful.key({ alt, }, ".",
        function()
            awful.client.focus.byidx(1)
        end,
        { description = "focus next window by index", group = "client" }
    ),
    awful.key({ alt, }, ",",
        function()
            awful.client.focus.byidx(-1)
        end,
        { description = "focus previous window by index", group = "client" }
    ),
    awful.key({ super, ctrl }, "j", function() awful.screen.focus_relative(1) end,
        { description = "focus the next screen", group = "screen" }),
    awful.key({ super, ctrl }, "k", function() awful.screen.focus_relative(-1) end,
        { description = "focus the previous screen", group = "screen" }),
    awful.key({ super, ctrl }, "n",
        function()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:activate { raise = true, context = "key.unminimize" }
            end
        end,
        { description = "restore minimized", group = "client" }),
}

-- Layout related keybindings
awful.keyboard.append_global_keybindings {
    awful.key({ alt, ctrl }, "j", function()
            awful.client.swap.global_bydirection("down")
        end,
        { description = "swap with window below", group = "client" }
    ),
    awful.key({ alt, ctrl }, "k", function()
            awful.client.swap.global_bydirection("up")
        end,
        { description = "swap with window above", group = "client" }
    ),
    awful.key({ alt, ctrl }, "h", function()
            awful.client.swap.global_bydirection("left")
        end,
        { description = "swap with window to the left", group = "client" }
    ),
    awful.key({ alt, ctrl }, "l", function()
            awful.client.swap.global_bydirection("right")
        end,
        { description = "swap with window to the right", group = "client" }
    ),
    awful.key({ super, }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),
    awful.key({ super, }, "k", function() awful.tag.incmwfact(0.05) end,
        { description = "increase master width factor", group = "layout" }),
    awful.key({ super, }, "j", function() awful.tag.incmwfact(-0.05) end,
        { description = "decrease master width factor", group = "layout" }),
    awful.key({ super, shift }, "h", function() awful.tag.incnmaster(1, nil, true) end,
        { description = "increase the number of master clients", group = "layout" }),
    awful.key({ super, shift }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
        { description = "decrease the number of master clients", group = "layout" }),
    awful.key({ super, ctrl }, "h", function() awful.tag.incncol(1, nil, true) end,
        { description = "increase the number of columns", group = "layout" }),
    awful.key({ super, ctrl }, "l", function() awful.tag.incncol(-1, nil, true) end,
        { description = "decrease the number of columns", group = "layout" }),
    awful.key({ super, }, "n", function() awful.layout.inc(1) end,
        { description = "select next", group = "layout" }),
    awful.key({ super, }, "p", function() awful.layout.inc(-1) end,
        { description = "select previous", group = "layout" }),
}


awful.keyboard.append_global_keybindings {
    awful.key {
        modifiers   = { super },
        keygroup    = "numrow",
        description = "only view tag",
        group       = "tag",
        on_press    = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
        end,
    },
    awful.key {
        modifiers   = { super, ctrl },
        keygroup    = "numrow",
        description = "toggle tag",
        group       = "tag",
        on_press    = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    },
    awful.key {
        modifiers   = { super, shift },
        keygroup    = "numrow",
        description = "move focused client to tag",
        group       = "tag",
        on_press    = function(index)
            if capi.client.focus then
                local tag = capi.client.focus.screen.tags[index]
                if tag then
                    capi.client.focus:move_to_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { super, ctrl, shift },
        keygroup    = "numrow",
        description = "toggle focused client on tag",
        group       = "tag",
        on_press    = function(index)
            if capi.client.focus then
                local tag = capi.client.focus.screen.tags[index]
                if tag then
                    capi.client.focus:toggle_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { super },
        keygroup    = "numpad",
        description = "select layout directly",
        group       = "layout",
        on_press    = function(index)
            local t = awful.screen.focused().selected_tag
            if t then
                t.layout = t.layouts[index] or t.layout
            end
        end,
    },
}

capi.client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings {
        --- Client move and resize
        awful.button({}, 1, function(c)
            c:activate { context = "mouse_click" }
        end),
        awful.button({ super }, 1, function(c)
            c:activate { context = "mouse_click", action = "mouse_move" }
        end),
        awful.button({ super }, 3, function(c)
            c:activate { context = "mouse_click", action = "mouse_resize" }
        end),
        --- Switch tags on super+scroll
        awful.button({ super }, 4, function(c) awful.tag.viewnext(c.screen) end),
        awful.button({ super }, 5, function(c) awful.tag.viewprev(c.screen) end),
    }
    awful.mouse.append_global_mousebindings {
        --- Switch tags on super+scroll
        awful.button({ super }, 4, awful.tag.viewnext),
        awful.button({ super }, 5, awful.tag.viewprev),
        --- Right click
        awful.button({
            modifiers = {},
            button = 3,
            on_press = function()
                main_menu:toggle()
            end,
        }),
    }
end)

capi.client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings {
        awful.key({ super, shift }, "f",
            function(c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            { description = "toggle fullscreen", group = "client" }),
        awful.key({ super, }, "q", function(c) c:kill() end,
            { description = "close", group = "client" }),
        awful.key({ super, }, "f", awful.client.floating.toggle,
            { description = "toggle floating", group = "client" }),
        awful.key({ super, ctrl }, "Return", function(c) c:swap(awful.client.getmaster()) end,
            { description = "move to master", group = "client" }),
        awful.key({ super, }, "o", function(c) c:move_to_screen() end,
            { description = "move to screen", group = "client" }),
        awful.key({ super, ctrl }, "t", function(c) c.ontop = not c.ontop end,
            { description = "toggle keep on top", group = "client" }),
        awful.key({ super, }, "n",
            function(c)
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                c.minimized = true
            end,
            { description = "minimize", group = "client" }),
        awful.key({ super, }, "m",
            function(c)
                c.maximized = not c.maximized
                c:raise()
            end,
            { description = "(un)maximize", group = "client" }),
        awful.key({ super, ctrl }, "m",
            function(c)
                c.maximized_vertical = not c.maximized_vertical
                c:raise()
            end,
            { description = "(un)maximize vertically", group = "client" }),
        awful.key({ super, shift }, "m",
            function(c)
                c.maximized_horizontal = not c.maximized_horizontal
                c:raise()
            end,
            { description = "(un)maximize horizontally", group = "client" }),
    }
end)

-- Function keys
awful.keyboard.append_global_keybindings {
    awful.key({}, "XF86AudioPlay", function()
        awful.spawn("playerctl play-pause")
    end, { description = "play/pause music", group = "Function keys" }),
    awful.key({}, "XF86AudioPrev", function()
        awful.spawn("playerctl previous")
    end, { description = "previous music", group = "Function keys" }),
    awful.key({}, "XF86AudioNext", function()
        awful.spawn("playerctl next")
    end, { description = "next music", group = "Function keys" }),
    awful.key({}, "XF86AudioMute", function()
        awful.spawn("amixer -D pipewire sset Master toggle")
    end, { description = "mute audio", group = "Function keys" }),
    awful.key({}, "XF86AudioLowerVolume", function()
        awful.spawn("amixer -D pipewire sset Master 5%-")
    end, { description = "decrease volume", group = "Function keys" }),
    awful.key({}, "XF86AudioRaiseVolume", function()
        awful.spawn("amixer -D pipewire sset Master 5%+")
    end, { description = "increase volume", group = "Function keys" }),
    -- TODO: make this work
    awful.key({}, "XF86MonBrightnessUp", function()
        awful.spawn("light -A 5%")
    end, { description = "increase brightness", group = "Function keys" }),
    awful.key({}, "XF86MonBrightnessDown", function()
        awful.spawn("light -U 5%")
    end, { description = "decrease brightness", group = "Function keys" }),
}
