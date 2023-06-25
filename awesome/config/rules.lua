local awful = require("awful")

awful.rules.rules = {
    
}

client.connect_signal("manage", function (c, startup)
    awful.client.movetoscreen(c, mouse.screen)
end)
