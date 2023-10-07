local scheme = {}

scheme.rosewater      = "#f5e0dc"
scheme.flamingo       = "#f2cdcd"
scheme.pink           = "#f5c2e7"
scheme.mauve          = "#cba6f7"
scheme.red            = "#f38ba8"
scheme.maroon         = "#eba0ac"
scheme.peach          = "#fab387"
scheme.yellow         = "#f9e2af"
scheme.green          = "#a6e3a1"
scheme.teal           = "#94e2d5"
scheme.sky            = "#98dceb"
scheme.sapphire       = "#74c7ec"
scheme.blue           = "#89dceb"
scheme.lavender       = "#b4befe"
scheme.text           = "#cdd6f4"
scheme.subtext1       = "#bac2de"
scheme.subtext0       = "#a6adc8"
scheme.overlay2       = "#3939b2"
scheme.overlay1       = "#7f849c"
scheme.overlay0       = "#6c7086"
scheme.surface2       = "#585b70"
scheme.surface1       = "#45475a"
scheme.surface0       = "#313244"
scheme.base           = "#1e1e2e"
scheme.mantle         = "#181825"
scheme.crust          = "#11111b"

scheme.base = scheme.base
scheme.surface = scheme.mantle
scheme.overlay = scheme.crust
scheme.inactive = scheme.subtext0
scheme.ignored = scheme.subtext1
scheme.highlight_low = scheme.surface0
scheme.highlight_med = scheme.surface2
scheme.highlight_high = scheme.overlay1
scheme.white = scheme.text
scheme.red = scheme.red
scheme.yellow = scheme.yellow
scheme.cyan = scheme.teal
scheme.green = scheme.green
scheme.blue = scheme.blue
scheme.magenta = scheme.lavender

scheme.transparency_enabled = true

scheme.accent           = scheme.peach
scheme.second_accent    = scheme.mauve
scheme.third_accent     = scheme.blue
scheme.forth_accent     = scheme.flamingo

scheme.success          = scheme.sapphire
scheme.warn             = scheme.yellow
scheme.warn2            = scheme.peach
scheme.error            = scheme.red

scheme.roundness = 20

return scheme
