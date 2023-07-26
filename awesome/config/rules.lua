local awful = require("awful")

awful.rules.rules = {
    {
        rule = { class = "Alacritty" },
        properties = {
            opacity = 1.0,
        }
    }
}

client.connect_signal("manage", function (c, startup)
    awful.client.movetoscreen(c, mouse.screen)
end)
