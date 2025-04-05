
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("i", "<localleader><leader>", "<ESC>")
vim.keymap.set("v", "<localleader><leader>", "<ESC>")

vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
