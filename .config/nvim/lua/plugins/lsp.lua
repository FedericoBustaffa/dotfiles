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
    },
    ft = 'lua', -- only load on lua files
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'folke/lazydev.nvim',
    },
    config = function()
      local lspconfig = require 'lspconfig'

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
