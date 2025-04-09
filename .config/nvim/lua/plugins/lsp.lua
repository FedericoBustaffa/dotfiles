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
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'mason.nvim' },
    lazy = false,
    opts = {
      ensure_installed = {
        -- LUA
        'lua-language-server',
        'stylua',
        -- C/C++
        'clangd',
        'clang-format',
        -- Python
        'python-lsp-server',
        'ruff',
        -- Bash
        'bash-language-server',
        'beautysh',
        -- Json
        'biome',
      },
      run_on_start = true,
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim' },
      {
        'folke/lazydev.nvim',
        ft = 'lua', -- only load on lua files
        opts = {
          library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
          },
        },
      },
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
