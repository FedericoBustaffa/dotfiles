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

vim.opt.updatetime = 250
vim.opt.timeoutlen = 1000
vim.opt.completeopt = { 'menuone', 'noselect', 'popup' }

vim.opt.showmode = false
vim.opt.lazyredraw = true

vim.diagnostic.config {
  virtual_text = {
    prefix = '●',
    spacing = 2,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
}
