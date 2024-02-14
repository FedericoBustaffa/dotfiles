return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua, -- Lua
				null_ls.builtins.formatting.clang_format, -- C/C++
				null_ls.builtins.diagnostics.cpplint,
				null_ls.builtins.diagnostics.pylint.with({
					diagnostics_postprocess = function(diagnostic)
						diagnostic.code = diagnostic.message_id
					end,
				}),
				null_ls.builtins.formatting.black, -- Python
				null_ls.builtins.formatting.isort,
			},
		})

		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
	end,
}
