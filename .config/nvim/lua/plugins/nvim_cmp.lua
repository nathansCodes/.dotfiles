return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lua",
        {
            "onsails/lspkind.nvim",
            config = function()
                require("lspkind").init()
            end
        }
    },
    config = function()
        vim.api.nvim_set_hl(0, "CmpDoc", { link="Pmenu" })

        local lspkind = require("lspkind")
        local cmp = require("cmp")
        cmp.setup {
            preselect = cmp.PreselectMode.Item,
            window = {
                completion = {
                    winhighlight = "Normal:Pmenu,CursorLine:PmenuSel,Search:PmenuSel",
                    scrollbar = false,
                },
                documentation = {
                    winhighlight = "Normal:CmpDoc",
                },
            },
            sorting = {
                priority_weight = 2,
            },
            formatting = {
                fields = { "abbr", "kind", "menu" },
                format = lspkind.cmp_format {
                    mode = 'symbol',
                    maxwidth = 50,
                    ellipsis_char = '...',
                    show_labelDetails = true,
                    before = function (entry, vim_item)
                        return vim_item
                    end
                },
            },
            performance = {
                async_budget = 1,
                max_view_entries = 120,
            },
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
            -- You should specify your *installed* sources.
            sources = {
                { name = "nvim_lsp", max_item_count = 350 },
                { name = "nvim_lua" },
                { name = "luasnip" },
                { name = "path" },
                { name = "treesitter" },
                { name = "spell" },
                { name = "tmux" },
                { name = "buffer" },
            },
            experimental = {
                ghost_text = {
                    hl_group = "Whitespace",
                },
            },
        }
    end
}
