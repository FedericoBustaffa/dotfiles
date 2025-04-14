return {
  {
    'williamboman/mason.nvim',
    lazy = false,
    ui = {
      icons = {
        package_installed = '✓',
        package_pending = '➜',
        package_uninstalled = '✗',
      },
    },
    config = function()
      require('mason').setup {}
    end,
  },
  {
    'williamboman/mason-lspconfig',
    lazy = false,
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      ensure_installed = {
        'lua_ls',
        'clangd',
        'cmake',
        'pylsp',
        'ruff',
        'bashls',
        'marksman',
        'biome',
      },
      automatic_installation = true,
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig',
      {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
          library = {
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
          },
        },
      },
      'saghen/blink.cmp',
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      local mason_lspconfig = require 'mason-lspconfig'
      local lspconfig = require 'lspconfig'

      local blink = require 'blink.cmp'
      local capabilities = blink.get_lsp_capabilities()

      mason_lspconfig.setup_handlers {
        function(server_name)
          lspconfig[server_name].setup {
            capabilities = capabilities,
          }
        end,
        ['lua_ls'] = function()
          lspconfig.lua_ls.setup { capabilities = capabilities }
        end,
        ['clangd'] = function()
          lspconfig.clangd.setup {
            capabilities = capabilities,
            cmd = {
              'clangd',
              '--clang-tidy',
              '--background-index',
              '--completion-style=detailed',
              '--header-insertion=never',
            },
          }
        end,
        ['cmake'] = function()
          lspconfig.cmake.setup { capabilities = capabilities }
        end,
        ['pylsp'] = function()
          lspconfig.pylsp.setup { capabilities = capabilities }
        end,
        ['biome'] = function()
          lspconfig.biome.setup { capabilities = capabilities }
        end,
        ['marksman'] = function()
          lspconfig.marksman.setup { capabilities = capabilities }
        end,
      }

      -- LSP keymaps
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go To Definition' })
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go To Implementation' })
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Actions' })
    end,
  },
}
