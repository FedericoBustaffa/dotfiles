vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- return to normal mode
vim.keymap.set("i", "<localleader><leader>", "<ESC>")
vim.keymap.set("v", "<localleader><leader>", "<ESC>")

-- save with Space + w
vim.keymap.set("n", "<leader>w", ":w<CR>")

-- move lines up and down
vim.keymap.set("n", "<A-k>", "ddkP", { silent = true })
vim.keymap.set("n", "<A-j>", "ddp", { silent = true })

-- move between panes with hjkl
vim.keymap.set("n", "<C-h>", ":wincmd h<CR>", { silent = true })
vim.keymap.set("n", "<C-j>", ":wincmd j<CR>", { silent = true })
vim.keymap.set("n", "<C-k>", ":wincmd k<CR>", { silent = true })
vim.keymap.set("n", "<C-l>", ":wincmd l<CR>", { silent = true })

-- move between panes with arrows
vim.keymap.set("n", "<C-Left>", ":wincmd h<CR>", { silent = true })
vim.keymap.set("n", "<C-Down>", ":wincmd j<CR>", { silent = true })
vim.keymap.set("n", "<C-Up>", ":wincmd k<CR>", { silent = true })
vim.keymap.set("n", "<C-Right>", ":wincmd l<CR>", { silent = true })

-- select all
vim.keymap.set("n", "<C-a>", "ggVG", { silent = true })

-- close buffer
vim.keymap.set("n", "<leader>q", ":q<CR>")

-- swap between last 2 buffers
vim.keymap.set("n", "<leader>p", "<C-^>", {})

-- jump to start/end of the line
vim.keymap.set("n", "L", "$", {})
vim.keymap.set("n", "H", "^", {})
vim.keymap.set("v", "L", "$<left>", {})
vim.keymap.set("v", "H", "^", {})

-- move lines
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv")

-- turn of serch results
vim.keymap.set("n", "<leader>no", ":noh<CR>", { silent = true })
