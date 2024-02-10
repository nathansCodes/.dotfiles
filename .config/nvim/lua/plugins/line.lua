local lualine = {
    "nvim-lualine/lualine.nvim",
    name = "lualine",
    dependencies = {
        { "nvim-tree/nvim-web-devicons", opt = true },
        "nvim-tree/nvim-tree.lua",
    },
    config = function()
        local theme = require("lualine.themes.catppuccin")
        local modes = { "normal", "insert", "visual", "replace", "command", "inactive" }
        for _, mode in ipairs(modes) do
            theme[mode].a = vim.api.nvim_get_hl(0, { name = "NvimTreeNormal" }).guibg
            theme[mode].b.bg = "none"
            theme[mode].c = theme[mode].c or {}
            theme[mode].c.bg = "none"
        end

        local function nvimtree_spacing()
            if require("nvim-tree.api").tree.is_visible() then
                return "                            "
            end
            return ""
        end

        require("lualine").setup {
            options = {
                icons_enabled = true,
                theme = theme,
                component_separators = { left = "", right = ""},
                section_separators = { left = "", right = ""},
                always_divide_middle = true,
                globalstatus = true,
                refresh = {
                    statusline = 1000,
                    tabline = 1000,
                    winbar = 1000,
                }
            },
            sections = {
                lualine_a = {nvimtree_spacing},
                lualine_b = {"mode", "branch"},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = {}
            },
            tabline = {},
            inactive_winbar = {},
            extensions = {
                "fugitive",
                "nvim-dap-ui",
            },
            winbar = {}
        }
    end,
}

local bufferline = {
    "akinsho/bufferline.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "nvim-tree/nvim-tree.lua",
    },
    opts = {
        options = {
            mode = "buffers",
            themable = false,
            diagnostics = "nvim_lsp",
            diagnostics_indicator = function(count, level, _, _)
                local icon = level:match("error") and " " or " "
                return " " .. icon .. count
            end,
            separator_style = "slant",
            hover = {
                enabled = true,
                delay = 200,
                reveal = {"close"}
            },
            diagnostics_update_in_insert = true,
            custom_areas = {
                left = function()
                    local result = {}
                    local nvimtree = require("nvim-tree.api")

                    if nvimtree.tree.is_visible() then
                        table.insert(result, {
                            text = "        File Explorer         ",
                            bg = vim.api.nvim_get_hl(0, { name = "NvimTreeNormal" }).bg
                        })
                    end
                    return result
                end
            }
        }
    },
}

return { lualine, bufferline }
