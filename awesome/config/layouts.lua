local awful = require("awful")

tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.tile,
        awful.layout.suit.spiral,
        awful.layout.suit.max,
        awful.layout.suit.max.fullscreen,
    })
end)
