vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

vim.opt.scrolloff = math.floor(vim.o.lines / 2) - 3
vim.opt.signcolumn = 'yes'
vim.opt.guicursor = ''

vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.showmatch = true

vim.opt.termguicolors = true
vim.opt.laststatus = 3

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.textwidth = 80
vim.opt.autoindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

vim.o.winborder = 'single'
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.updatetime = 50
vim.opt.timeoutlen = 500
vim.opt.completeopt = { 'menuone', 'noselect', 'fuzzy', 'nosort' }

vim.opt.showmode = false
vim.opt.lazyredraw = false
