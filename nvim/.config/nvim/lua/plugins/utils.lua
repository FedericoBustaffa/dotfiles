vim.pack.add({
	{ src = "https://github.com/folke/which-key.nvim", name = "which-key" },
	{ src = "https://github.com/windwp/nvim-autopairs", name = "autopairs" },
	{ src = "https://github.com/christoomey/vim-tmux-navigator", name = "tmux-navigator" },
})

vim.keymap.set("n", "<leader>?", function()
	require("which-key").show({ global = false })
end, { desc = "Buffer Local Keymaps (which-key)" })

vim.keymap.set("n", "<C-h>", "<CMD>TmuxNavigateLeft<CR>")
vim.keymap.set("n", "<C-j>", "<CMD>TmuxNavigateDown<CR>")
vim.keymap.set("n", "<C-k>", "<CMD>TmuxNavigateUp<CR>")
vim.keymap.set("n", "<C-l>", "<CMD>TmuxNavigateRight<CR>")
