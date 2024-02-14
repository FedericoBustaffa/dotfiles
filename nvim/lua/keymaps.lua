
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

