
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- return to normal mode
vim.keymap.set("i", "<localleader><leader>", "<ESC>")
vim.keymap.set("v", "<localleader><leader>", "<ESC>")

-- save with Space + w
vim.keymap.set("n", "<leader>w", ":w<CR>")

-- move lines up and down
vim.keymap.set("n", "<A-k>", "ddkP")
vim.keymap.set("n", "<A-j>", "ddp")

-- move between panes with hjkl
vim.keymap.set("n", "<C-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<C-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<C-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<C-l>", ":wincmd l<CR>")

-- move between panes with arrows
vim.keymap.set("n", "<C-Left>", ":wincmd h<CR>")
vim.keymap.set("n", "<C-Down>", ":wincmd j<CR>")
vim.keymap.set("n", "<C-Up>", ":wincmd k<CR>")
vim.keymap.set("n", "<C-Right>", ":wincmd l<CR>")
