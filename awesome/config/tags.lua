local awful = require("awful")
local gears = require("gears")
local gfs = gears.filesystem

local helpers = require("helpers")

screen.connect_signal("request::desktop_decoration", function(s)
    awful.tag.add("main", {
        screen = s,
        icon = "\u{e86f}",
        layout = awful.layout.suit.tile,
        selected = true,
        index = 1,
    })

    awful.tag.add("web", {
        screen = s,
        icon = "\u{e80b}",
        layout = awful.layout.suit.tile,
        index = 2,
    })

    awful.tag.add("file", {
        screen = s,
        icon = "\u{e873}",
        layout = awful.layout.suit.tile,
        index = 3,
    })

    awful.tag.add("chat", {
        screen = s,
        icon = "\u{e8cd}",
        layout = awful.layout.suit.tile,
        index = 4,
    })

    awful.tag.add("misc", {
        screen = s,
        icon = "\u{e8b8}",
        layout = awful.layout.suit.tile,
        index = 5,
    })
end)
