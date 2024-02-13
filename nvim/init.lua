vim.cmd('set nocompatible')
vim.cmd('set encoding=UTF-8')
vim.cmd('set tabstop=4')
vim.cmd('set shiftwidth=4')
vim.cmd('set autoindent')
vim.cmd('set smartindent')
vim.cmd('set number')
vim.cmd('set relativenumber')
vim.cmd('set mouse=a')
vim.cmd('set hlsearch')
vim.cmd('set incsearch')
vim.cmd('set hidden')
vim.cmd('set fdm=indent')
vim.cmd('set foldlevelstart=99')
vim.cmd('set ignorecase')
vim.cmd('set smartcase')
vim.cmd('set splitbelow')
vim.cmd('set splitright')
vim.cmd('set completeopt-=preview')

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

local plugins = {
  { "catppuccin/nvim",                 name = "catppuccin", priority = 1000 },
  { 'nvim-telescope/telescope.nvim',   tag = '0.1.5',       dependencies = { 'nvim-lua/plenary.nvim' } },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" }
}

local opts = {}

require("lazy").setup(plugins, opts)

require("catppuccin").setup()
vim.cmd.colorscheme "catppuccin"

local builtin = require("telescope.builtin")
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})

local config = require("nvim-treesitter.configs")
config.setup({
  ensure_installed = {
    "java",
    "cpp",
    "python",
    "c",
    "lua",
    "vim"
  },
  sync_install = false,
  highlight = { enable = true },
  indent = { enable = true },
})
