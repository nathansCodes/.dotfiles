local awful = require("awful")

-- policy kit
awful.spawn.with_shell("/usr/libexec/polkit-gnome-authentication-agent-1")

-- screen layout
awful.spawn("/home/nathan/.screenlayout/default.sh")

-- wallpaper
awful.spawn.with_shell("nitrogen --restore")

-- compositor
awful.spawn.with_shell("picom --experimental-backends")

-- clipboard
awful.spawn.with_shell("CM_OWN_CLIPBOARD=1 clipmenud")

