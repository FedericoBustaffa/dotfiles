return {
	{
		"mfussenegger/nvim-dap",
		config = function()
			local dap = require("dap")

			-- Keybindings
			vim.keymap.set("n", "<Leader>db", function()
				dap.toggle_breakpoint()
			end)
			vim.keymap.set("n", "<leader>dc", function()
				dap.continue()
			end)
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			local dap = require("dap")
			dap.adapters.gdb = {
				type = "executable",
				command = "gdb",
				-- args = { "-i", "dap" },
			}
			dap.configurations.cpp = {
				{
					name = "Launch",
					type = "gdb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopAtBeginningOfMainSubprogram = false,
				},
			}

			local dapui = require("dapui")

			dapui.setup()

			-- GUI
			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
		end,
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"mfussenegger/nvim-dap",
		},
		config = function()
			require("mason-nvim-dap").setup({
				ensure_installed = {
					"cpptools",
				},
			})
		end,
	},
}
