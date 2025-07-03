-- highlight the yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Mostra automaticamente il popup quando il cursore si ferma
vim.api.nvim_create_autocmd('CursorHold', {
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
