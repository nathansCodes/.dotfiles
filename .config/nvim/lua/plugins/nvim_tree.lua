return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local nvtree = require("nvim-tree")

        nvtree.setup { }

        vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeOpen<cr>")

        -- auotmatically open nvim-tree on enter
        -- if no file was/no arguments were passed
        vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
                vim.cmd.NvimTreeOpen()
            end
        })
    end
}
