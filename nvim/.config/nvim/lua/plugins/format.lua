vim.pack.add({
	{ src = "https://github.com/stevearc/conform.nvim", name = "conform" },
	{ src = "https://github.com/mfussenegger/nvim-lint", name = "lint" },
})

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		python = { "ruff_format", "ruff_organize_imports" },
		json = { "biome" },
		bash = { "beautysh" },
		sh = { "beautysh", "shellcheck" },
		zsh = { "beautysh" },
		markdown = { "prettier" },
		css = { "prettier" },
		latex = { "latexindent" },
		typst = { "typstyle" },
	},
	format_on_save = true,
	undojoin = true,
})

local lint = require("lint")

-- Auto-run the linter only for the configured filetypes
vim.api.nvim_create_autocmd("BufWritePost", {
	callback = function()
		local ft = vim.bo.filetype
		if lint.linters_by_ft[ft] then
			lint.try_lint()
		end
	end,
})
