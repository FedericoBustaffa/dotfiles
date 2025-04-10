return {
  {
    'williamboman/mason.nvim',
    ui = {
      icons = {
        package_installed = '✓',
        package_pending = '➜',
        package_uninstalled = '✗',
      },
    },
    opts = {},
  },
  {
    'williamboman/mason-lspconfig',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      ensure_installed = {
        'lua_ls',
        'clangd',
        'pylsp',
        'ruff',
        'bashls',
        'biome',
      },
    },
  },
  {
    'folke/lazydev.nvim',
    dependencies = {
      'williamboman/mason-lspconfig',
      'neovim/nvim-lspconfig',
    },
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig',
      'folke/lazydev.nvim',
      'saghen/blink.cmp',
    },
    config = function()
      local lspconfig = require 'lspconfig'
      local blink = require 'blink.cmp'

      blink.get_lsp_capabilities()

      lspconfig.lua_ls.setup {}
      lspconfig.clangd.setup {
        cmd = {
          'clangd',
          '--clang-tidy',
          '--background-index',
          '--completion-style=detailed',
          '--header-insertion=never',
        },
      }
      lspconfig.biome.setup {}
      lspconfig.pylsp.setup {}
    end,
  },
}
