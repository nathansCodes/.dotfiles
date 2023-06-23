local awful = require("awful")

-- screen layout
awful.spawn("/home/nathan/.screenlayout/default.sh")

-- compositor
awful.spawn.with_shell("picom")

-- wallpaper
awful.spawn.with_shell("nitrogen --restore")
