vim.pack.add({
	{ src = "https://github.com/nvim-telescope/telescope.nvim", name = "telescope" },
	{ src = "https://github.com/nvim-lua/plenary.nvim", name = "plenary" },
	{ src = "https://github.com/nvim-telescope/telescope-symbols.nvim", name = "telescope-symbols" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim", name = "telescope-ui-select" },
	{ src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim", name = "telescope-fzf-native" },
	{ src = "https://github.com/nvim-telescope/telescope-file-browser.nvim", name = "telescope-file-browser" },
	{ src = "https://github.com/2kabhishek/nerdy.nvim", name = "telescope-nerdy" },
})

vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#89b4fa" })

local actions = require("telescope.actions")
require("telescope").setup({
	defaults = {
		file_ignore_patterns = {
			"%.jpg",
			"%.jpeg",
			"%.png",
			"%.svg",
			"%.gif",
			"%.webp",
			"%.pdf",
			"%.zip",
			"build/",
			".cache/",
			"%.git/",
			"%.obsidian/",
			"%.egg-info/*",
			".git/",
			".venv",
			".node_modules",
			"node_modules",
			".svelte-kit",
			".vscode",
		},
	},
	pickers = {
		buffers = {
			show_all_buffers = true,
			mappings = {
				i = {
					["<CR>"] = actions.select_drop,
				},
				n = {
					["<CR>"] = actions.select_drop,
					["d"] = actions.delete_buffer,
				},
			},
		},
		find_files = {
			show_all_buffers = true,
			mappings = {
				i = {
					["<CR>"] = actions.select_drop,
				},
				n = {
					["<CR>"] = actions.select_drop,
				},
			},
		},
		live_grep = {
			additional_args = function()
				return { "--hidden" }
			end,
		},
	},
	extensions = {
		file_browser = {
			theme = "ivy",
			hijack_netrw = true,
		},
		["ui-select"] = {
			require("telescope.themes").get_dropdown({
				-- even more opts
			}),
		},
	},
})

-- build fzf
vim.system({ "make" }, {
	cwd = vim.pack.get({ "telescope-fzf-native" })[1].path,
}):wait()

-- load extensions
require("telescope").load_extension("fzf")
require("telescope").load_extension("file_browser")
require("telescope").load_extension("ui-select")
require("telescope").load_extension("nerdy")

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", function()
	builtin.find_files({ hidden = true })
end)

vim.keymap.set("n", "<space>e", function()
	require("telescope").extensions.file_browser.file_browser()
end)

vim.keymap.set("n", "<space>fn", function()
	local full_path = vim.api.nvim_buf_get_name(0)
	local dir = vim.fn.fnamemodify(full_path, ":h")
	require("telescope").extensions.file_browser.file_browser({
		path = dir,
	})
end)

vim.keymap.set("n", "<leader>fg", function()
	builtin.live_grep({ hidden = true })
end)

vim.keymap.set("n", "<leader>fb", function()
	builtin.buffers({ show_all_buffers = true })
end)

vim.keymap.set("n", "<leader>fc", function()
	require("telescope.builtin").find_files({
		cwd = vim.fn.stdpath("config"),
	})
end, { desc = "Find Config Files" })

vim.keymap.set("n", "<leader>D", function()
	require("telescope.builtin").diagnostics()
end, { desc = "Diagnostics" })

vim.keymap.set("n", "<leader>fs", function()
	require("telescope.builtin").lsp_document_symbols()
end, { desc = "Find Document Symbols" })

vim.keymap.set("n", "<leader>fws", function()
	require("telescope.builtin").lsp_workspace_symbols()
end, { desc = "Find Workspace Symbols" })
