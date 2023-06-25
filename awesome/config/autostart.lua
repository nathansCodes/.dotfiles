local awful = require("awful")

-- screen layout
awful.spawn("/home/nathan/.screenlayout/default.sh")

-- compositor
awful.spawn.with_shell("picom -b")

-- wallpaper
awful.spawn.with_shell("nitrogen --restore")

-- clipboard
awful.spawn.with_shell("CM_OWN_CLIPBOARD=1 clipmenud")

