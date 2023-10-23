local awful = require("awful")

awful.rules.rules = {
    {
        rule = { class = "Gimp-.*" },
        properties = {
            opacity = 1.0,
        }
    },
    {
        rule = { class = "Inkscape" },
        properties = {
            opacity = 1.0,
        }
    },
    {
        rule = { class = "Alacritty" },
        properties = {
            opacity = 1.0,
        }
    },
}
