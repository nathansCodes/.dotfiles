return {
    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v2.x",
        dependencies = {
            -- LSP Support
            { "neovim/nvim-lspconfig" },
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },

            -- Autocompletion
            { "hrsh7th/nvim-cmp" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-path" },
            { "saadparwaiz1/cmp_luasnip" },
            { "hrsh7th/cmp-nvim-lua" },

            -- Snippets
            { "L3MON4D3/LuaSnip" },
            { "rafamadriz/friendly-snippets" },
        },
        config = function()
            local lsp = require("lsp-zero")

            lsp.preset("recommended")

            lsp.ensure_installed {
                "clangd",
                "rust_analyzer",
                "lua_ls",
            }

            -- Fix Undefined global "vim"
            lsp.configure("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" }
                        }
                    }
                }
            })

            local cmp = require("cmp")
            local cmp_select = {behaviour = cmp.SelectBehavior.Select}
            local cmp_mappings = lsp.defaults.cmp_mappings {
                ["<C-k>"] = cmp.mapping.select_prev_item(cmp_select),
                ["<C-j>"] = cmp.mapping.select_next_item(cmp_select),
                ["<C-y>"] = cmp.mapping.confirm({ select = true }),
                ["<C-g>"] = cmp.mapping.complete(),
            }

            lsp.setup_nvim_cmp {
                mapping = cmp_mappings,
            }

            lsp.set_preferences {
                sign_icons = { },
            }

            lsp.on_attach(function(client, bufnr)
                local opts = {buffer = bufnr, remap = true}

                vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
                vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
                vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
                vim.keymap.set("n", "<leader>vd", function() vim.lsp.buf.open_float() end, opts)
                vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
                vim.keymap.set("n", "]d", function() vim.diagnostc.goto_prev() end, opts)
                vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
                vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
                vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
                vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)

                vim.lsp.codelens.refresh()
            end)

            lsp.setup()

            vim.diagnostic.config {
                virtual_text = true,
                signs = false,
                update_in_insert = true,
                underline = true,
                severity_sort = false,
                float = true,
            }

        end,
    },
    -- rofi config highlighting
    {
        "Fymyte/rasi.vim",
        ft = "rasi",
        dependencies = {
            "ap/vim-css-color"
        },
    },
}
