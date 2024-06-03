-- Treesitter serve a creare AST per il linguaggio di turno
-- serve per avere highlighting, e indentazione

return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local config = require("nvim-treesitter.configs")
		config.setup({
			modules = {},
			auto_install = false,
			ignore_install = {},
			ensure_installed = {
				"java",
				"cpp",
				"python",
				"c",
				"cuda",
				"lua",
				"latex",
				"bibtex",
				"haskell",
				"glsl",
			},
			sync_install = false,
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
