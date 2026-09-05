vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter", name = "treesitter" } })

local treesitter = require("nvim-treesitter")

treesitter.setup({
	highlight = { enable = true },
	indent = { enable = true },
	auto_install = true,
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		pcall(vim.treesitter.start)
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})

local ensureInstalled = {
	"bash",
	"html",
	"css",
	"latex",
	"markdown_inline",
	"query",
	"yaml",
	"lua",
	"python",
	"c",
	"cpp",
	"bash",
	"json",
	"typst",
	"markdown",
	"latex",
	"rust",
}

local alreadyInstalled = require("nvim-treesitter.config").get_installed()
local parsersToInstall = vim.iter(ensureInstalled)
	:filter(function(parser)
		return not vim.tbl_contains(alreadyInstalled, parser)
	end)
	:totable()

treesitter.install(parsersToInstall)
