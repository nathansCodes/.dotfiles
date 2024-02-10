function Colors()
    -- this will be changed by my awm theme switcher
    vim.cmd.colorscheme("catppuccin-mocha")
end

return {
    "ap/vim-css-color",
    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = true,
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = true,
        opts = {
            term_colors = true,
            color_overrides = {
                mocha = {
                    mantle = "#181825",
                }
            },
            integrations = {
                telescope = {
                    enabled = true,
                    style = "nvchad",
                },
            }
        }
    },
    {
        "Biscuit-Colorscheme/nvim",
        name = "biscuit",
        lazy = true,
    },
}
