return {
    "nvim-telescope/telescope.nvim", tag = "0.1.x",
    dependencies = { { "nvim-lua/plenary.nvim" } },
    config = function()
        local builtin = require('telescope.builtin')
        local actions = require('telescope.actions')

        vim.keymap.set('n', '<leader>f', builtin.find_files, {})
        vim.keymap.set('n', '<leader>g', builtin.git_files, {})
        vim.keymap.set('n', '<leader>s', function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end)

        require("telescope").setup {
            defaults = {
                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-l>"] = actions.select_default,
                        ["<C-u>"] = actions.results_scrolling_up,
                        ["<C-d>"] = actions.results_scrolling_down,
                    },
                    n = {
                        ["l"] = actions.select_default,
                        ["u"] = actions.results_scrolling_up,
                        ["d"] = actions.results_scrolling_down,
                    },
                }
            }
        }
    end,
}
