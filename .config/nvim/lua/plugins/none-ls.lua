return {
	{
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"nvimtools/none-ls.nvim",
		},
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = {
					"stylua",
					"clang_format",
					"black",
					"isort",
					"pylint",
					"biome",
				},
			})
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua, -- Lua
					null_ls.builtins.formatting.clang_format, -- C/C++
					null_ls.builtins.diagnostics.cppcheck,
					null_ls.builtins.formatting.black, -- Python
					null_ls.builtins.formatting.isort,
					null_ls.builtins.diagnostics.pylint.with({
						only_local = ".env/bin/",
					}),
					null_ls.builtins.formatting.biome,
				},
			})
		end,
	},
}
