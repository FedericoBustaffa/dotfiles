-- Autocommands
local augroup = vim.api.nvim_create_augroup('UserConfig', {})

-- highlight the yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = augroup,
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Mostra automaticamente il popup quando il cursore si ferma
vim.api.nvim_create_autocmd('CursorHold', {
  group = augroup,
  callback = function()
    -- Non aprire se c'è già un float visibile
    local float_open = false
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local config = vim.api.nvim_win_get_config(win)
      if config.relative ~= '' then
        float_open = true
        break
      end
    end

    if not float_open then
      vim.diagnostic.open_float(nil, {
        focusable = false,
        close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
        border = 'rounded',
        source = 'always',
        prefix = '',
        scope = 'cursor',
      })
    end
  end,
})

-- Return to the last edit position when opening a file
vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
