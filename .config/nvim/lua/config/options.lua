vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 12
vim.opt.signcolumn = 'yes'

vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.showmatch = true

vim.opt.termguicolors = true
vim.opt.laststatus = 3

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.updatetime = 50
vim.opt.timeoutlen = 500
vim.opt.completeopt = { 'menuone', 'noselect', 'popup' }

vim.opt.showmode = false
vim.opt.lazyredraw = true

vim.diagnostic.config {
  virtual_text = false,
  signs = true,
  underline = true,
  float = {
    border = 'rounded',
    source = true,
    header = '',
    prefix = '',
  },
}

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
