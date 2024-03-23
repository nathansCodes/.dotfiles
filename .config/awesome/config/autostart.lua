local awful = require("awful")
local user_settings = require("config.user_settings")

-- policy kit
awful.spawn.once("/usr/libexec/polkit-gnome-authentication-agent-1")

-- unlock keyring
awful.spawn.once("gnome-keyring-daemon -s")

-- compositor
if user_settings.theme.compositor_enabled then
    awful.spawn.with_shell("picom")
end

-- Kill picom so that it doesn't behave weirdly after restart
-- I know that this doesn't count as an "autostart" but idk where else to put this
awesome.connect_signal("exit", function() awful.spawn("killall picom") end)

-- start user-specified autostart programs
local user_autostart_programs = user_settings.program.autostart or {}

for _, k in ipairs(user_autostart_programs) do
    local type = string.lower(k.type)

    local spawn_func = getmetatable(awful.spawn).__call
    if type == "daemon" or type == "startup" then
        spawn_func = awful.spawn.once
    elseif type == "app" then
        spawn_func = awful.spawn.raise_or_spawn
    elseif type == "command" then
        spawn_func = awful.spawn.with_shell
    end

    spawn_func(k.program)
end

