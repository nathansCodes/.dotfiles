local awful = require("awful")
local user_settings = require("config.user_settings")

-- policy kit
awful.spawn.once("/usr/libexec/polkit-gnome-authentication-agent-1")

-- KWallet
awful.spawn.once("kwalletd5")

-- clipboard
awful.spawn.once("CM_OWN_CLIPBOARD=1 clipmenud")

-- compositor
awful.spawn.with_shell("picom")


awful.spawn.with_shell("export XDG_CURRENT_DESKTOP=awesome")

-- Kill picom so that it doesn't behave weirdly after restart
-- I know that this doesn't count as an "autostart" but idk where else to put this
awesome.connect_signal("exit", function(reason_restart)
    if reason_restart then awful.spawn("killall picom") end
end)

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

