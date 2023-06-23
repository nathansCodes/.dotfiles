local awful = require("awful")

-- compositor
awful.spawn.with_shell("picom --animations --animation-for-open-window zoom")

-- wallpaper
awful.spawn.with_shell("nitrogen --restore")

-- screen layout
awful.spawn("/home/nathan/.screenlayout/default.sh")
