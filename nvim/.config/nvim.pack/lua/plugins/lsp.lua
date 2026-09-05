vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig", name = "lspconfig" },
	{ src = "https://github.com/saghen/blink.cmp", name = "blink" },
	{ src = "https://github.com/saghen/blink.lib", name = "blink-lib" },
	{ src = "https://github.com/folke/lazydev.nvim", name = "lazydev" },
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

vim.lsp.config("*", {
	on_attach = function(_, bufnr)
		local opts = { buffer = bufnr, silent = true }
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	end,
	capabilities = capabilities,
})

-- Only show diagnostics close to the cursor
vim.diagnostic.config({
	virtual_text = {
		spacing = 4,
		prefix = function(diagnostic)
			local icons = {
				[vim.diagnostic.severity.ERROR] = " ",
				[vim.diagnostic.severity.WARN] = "󰉀 ",
				[vim.diagnostic.severity.INFO] = " ",
				[vim.diagnostic.severity.HINT] = "󰌵 ",
			}
			return icons[diagnostic.severity] or ""
		end,
	},
	signs = false,
	underline = true,
	update_in_insert = false,
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			-- Tell the server to let Neovim handle snippet expansion
			completion = {
				callSnippet = "Replace",
			},
			-- Use LuaJIT (which Neovim uses)
			runtime = {
				version = "LuaJIT",
			},
		},
	},
})

vim.lsp.enable({
	"lua_ls",
	"clangd",
	"neocmake",
	"ty",
	"bashls",
	"marksman",
	"biome",
	"bashls",
	"shellcheck",
	"texlab",
	"tinymist",
	"qmlls",
})

require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})

vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = "#89b4fa" })

require("blink.cmp").build():pwait()

require("blink.cmp").setup({
	fuzzy = { implementation = "rust" },

	keymap = { preset = "default" },

	signature = { enabled = true },

	completion = {
		trigger = {
			show_on_insert = true,
			show_on_trigger_character = true,
			show_on_keyword = true,
			show_on_backspace = true,
		},
		list = {
			selection = {
				preselect = false,
				auto_insert = true,
			},
		},
		menu = {
			border = "single",
			scrolloff = 1,
			-- min_width = 35,
			draw = {
				columns = {
					{ "kind_icon" },
					{ "label", "label_description", gap = 1 },
					{ "kind" },
					{ "source_name" },
				},
			},
		},
		documentation = {
			window = { border = "single" },
			auto_show = true,
		},
	},

	sources = {
		default = { "lazydev", "lsp", "path", "snippets", "buffer" },
		providers = {
			lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				score_offset = 100,
			},
		},
	},

	appearance = {
		use_nvim_cmp_as_default = false,
		nerd_font_variant = "mono",
	},
})
