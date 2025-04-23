vim.g.mapleader = " "

local wk = require("which-key")

-- general remaps
wk.add {
    { "J", ":m '>+1<CR>gv=gv", mode = "v" },
    { "K", ":m '<-2<CR>gv=gv", mode = "v" },
    { "J", "mzJ`z", mode = "n" },
    { "<C-d>", "<C-d>zz", mode = "n" },
    { "<C-u>", "<C-u>zz", mode = "n" },
    { "n", "nzzzv", mode = "n" },
    { "N", "Nzzzv", mode = "n" },

    { "<C-c>", "<Esc>", mode = "i" },
    { "<C-c>", "<Esc>", mode = "v" },

    { "<leader>y", '"+y', mode = "v" },
    { "<leader>y", '"+y', mode = "n" },
}

-- remaps for splits
wk.add {
    {
        mode = { "n", "t" },
        { "<C-->", "<C-W>-" },
        { "<C-_>", "<C-W>_" },
        { "<C-+>", "<C-W>+" },
        { "<C-=>", "<C-W>=" },
        { "<C-|>", "<C-W>|" },
    },
}

-- plugin keymaps
wk.add {
    { "<leader>gs", vim.cmd.Git, mode = "n" },

    { "<leader>u", vim.cmd.UndotreeToggle, mode = "n" },

    { "<leader>j", vim.cmd.BufferLineMovePrev, mode = "n" },
    { "<leader>k", vim.cmd.BufferLineMoveNext, mode = "n" },
    { "<leader>t", vim.cmd.BufferLinePick, mode = "n" },
    { "<leader>xh", vim.cmd.BufferLineCloseLeft, mode = "n" },
    { "<leader>xl", vim.cmd.BufferLineCloseRight, mode = "n" },

    { "<leader>ct", vim.cmd.CommentToggle, mode = "n" },
    { "<leader>ct", ":'<,'>CommentToggle<cr>", mode = "v" },
}
