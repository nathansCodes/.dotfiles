vim.g.mapleader = " "

-- general remaps
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<leader>o", "<C-^>")

vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("v", "<C-c>", "<Esc>")

vim.keymap.set("x", "<leader>p", "\"_dP")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>y", "\"+y")

-- remaps for splits
vim.keymap.set({ 'n', 't' }, '<C-->', '<C-W>-')
vim.keymap.set({ 'n', 't' }, '<C-_>', '<C-W>_')
vim.keymap.set({ 'n', 't' }, '<C-+>', '<C-W>+')
vim.keymap.set({ 'n', 't' }, '<C-=>', '<C-W>=')
vim.keymap.set({ 'n', 't' }, '<C-|>', '<C-W>|')

vim.keymap.set("c", "<C-k>", "<C-p>")
vim.keymap.set("c", "<C-j>", "<C-n>")

-- plugin keymaps
vim.keymap.set("n", "<leader>gs", vim.cmd.Git                )
vim.keymap.set("n", "<leader>u",  vim.cmd.UndotreeToggle     )
vim.keymap.set("n", "<leader>h",  vim.cmd.BufferLineCyclePrev)
vim.keymap.set("n", "<leader>l",  vim.cmd.BufferLineCycleNext)
vim.keymap.set("n", "<leader>j",  vim.cmd.BufferLineMovePrev )
vim.keymap.set("n", "<leader>k",  vim.cmd.BufferLineMoveNext )

