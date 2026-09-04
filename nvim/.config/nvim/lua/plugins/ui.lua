vim.pack.add({
	{ src = "https://github.com/nvim-lualine/lualine.nvim", name = "lualine" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons", name = "devicons" },
	{ src = "https://github.com/j-hui/fidget.nvim", name = "fidget" },
	{ src = "https://github.com/lukas-reineke/indent-blankline.nvim", name = "indentline" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim", name = "gitsigns" },
	{ src = "https://github.com/echasnovski/mini.nvim", name = "mini" },
	{ src = "https://github.com/echasnovski/mini.notify", name = "notify" },
	{ src = "https://github.com/folke/snacks.nvim", name = "snacks" },
	{ src = "https://github.com/akinsho/toggleterm.nvim", name = "terminal" },
})

require("lualine").setup({
  options = {
    theme = "auto"
  }
})

require("ibl").setup({
	scope = { enabled = false },
})

require("gitsigns").setup({
	signs = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
		untracked = { text = "▎" },
	},
	signs_staged = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
	},
})

require("mini.icons").setup()

require("mini.notify").setup({
	window = {
		config = {},
		max_width_share = 0.5,
	},
})

require("snacks").setup({
	animate = { enabled = false },
	bigfile = { enabled = true },
	bufdelete = { enabled = true },
	dashboard = { enabled = false },
	git = { enabled = true },
	lazygit = { enabled = true },
})

local snacks = require("snacks")

vim.keymap.set("n", "<leader>bd", function()
	snacks.bufdelete()
end, { desc = "Delete Buffer" })

vim.keymap.set("n", "<leader>lg", function()
	snacks.lazygit()
end, { desc = "LazyGit" })

require("toggleterm").setup({
	direction = "float",
	float_opts = {
		border = "curved",
	},
	open_mapping = [[<A-p>]],
})
