return {
	{
		"tpope/vim-fugitive",
	},
	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		config = function()
			require("gitsigns").setup()
			vim.keymap.set("n", "<leader>gh", ":Gitsigns preview_hunk_inline<CR>")
		end,
	},
}
