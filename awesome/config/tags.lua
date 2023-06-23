local awful = require("awful")
local gears = require("gears")
local gfs = gears.filesystem

screen.connect_signal("request::desktop_decoration", function(s)
    awful.tag.add("main", {
        screen = s,
        gap_single_client = true,
        gap = 6,
        layout = awful.layout.suit.tile,
        selected = true,
        index = 1,
    })

    awful.tag.add("web", {
        screen = s,
        gap_single_client = true,
        gap = 6,
        layout = awful.layout.suit.tile,
        index = 2,
    })

    awful.tag.add("file", {
        screen = s,
        gap_single_client = true,
        gap = 6,
        layout = awful.layout.suit.tile,
        index = 3,
    })

    awful.tag.add("chat", {
        screen = s,
        gap_single_client = true,
        gap = 6,
        layout = awful.layout.suit.tile,
        index = 4,
    })

    awful.tag.add("misc", {
        screen = s,
        gap_single_client = true,
        gap = 6,
        layout = awful.layout.suit.tile,
        index = 5,
    })
end)
