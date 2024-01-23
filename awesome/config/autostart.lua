local awful = require("awful")
local user_settings = require("config.user_settings")

-- policy kit
awful.spawn.once("/usr/libexec/polkit-gnome-authentication-agent-1")

-- KWallet
awful.spawn.once("kwalletd5")

-- clipboard
awful.spawn.once("CM_OWN_CLIPBOARD=1 clipmenud")

-- compositor
awful.spawn.with_shell("compfy")

-- Kill compfy so that it doesn't behave weirdly after restart
-- I know that this doesn't count as an "autostart" but idk where else to put this
awesome.connect_signal("exit", function(reason_restart)
    if reason_restart then awful.spawn("killall compfy") end
end)

-- start user-specified autostart programs
local user_autostart_programs = user_settings.get("program.autostart")

if user_autostart_programs == nil then return end

for _, k in ipairs(user_autostart_programs) do
    k.type = string.lower(k.type)

    local spawn_func = getmetatable(awful.spawn).__call
    if k.type == "daemon" or k.type == "startup" then
        spawn_func = awful.spawn.once
    elseif k.type == "app" then
        spawn_func = awful.spawn.raise_or_spawn
    elseif k.type == "command" then
        spawn_func = awful.spawn.with_shell
    end

    spawn_func(k.program)
end

