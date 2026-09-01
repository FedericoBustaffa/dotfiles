-- Autocommands
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

-- Autocommand to check git status
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		-- Verify if the current directory is a git repo
		local is_git = os.execute("git rev-parse --is-inside-work-tree > /dev/null 2>&1")
		if is_git ~= 0 then
			return
		end

		-- Perform an async fetch to avoid startup lag
		vim.fn.jobstart("git fetch", {
			on_exit = function()
				-- Get the number of commits the remote is ahead of local HEAD
				local count = vim.fn.system("git rev-list --count HEAD..@{u} 2>/dev/null"):gsub("%s+", "")

				if count ~= "" and tonumber(count) > 0 then
					vim.schedule(function()
						vim.notify(
							"󰊢 " .. count .. " new commit(s) available on remote.",
							vim.log.levels.INFO,
							{ title = "Git Status", icon = "󰊢" }
						)
					end)
				end
			end,
		})
	end,
})

-- Enable and disable cursor line
local cursorline_group = vim.api.nvim_create_augroup("CursorLineControl", { clear = true })

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
	group = cursorline_group,
	callback = function()
		vim.opt_local.cursorline = true
	end,
})

vim.api.nvim_create_autocmd({ "WinLeave" }, {
	group = cursorline_group,
	callback = function()
		vim.opt_local.cursorline = false
	end,
})

-- highlight the yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = augroup,
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Mostra automaticamente il popup quando il cursore si ferma
vim.api.nvim_create_autocmd("CursorHold", {
	group = augroup,
	callback = function()
		-- Non aprire se c'è già un float visibile
		local float_open = false
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local config = vim.api.nvim_win_get_config(win)
			if config.relative ~= "" then
				float_open = true
				break
			end
		end

		if not float_open then
			vim.diagnostic.open_float(nil, {
				focusable = false,
				close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
				border = "rounded",
				source = "always",
				prefix = "",
				scope = "cursor",
			})
		end
	end,
})

-- Return to the last edit position when opening a file
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})
