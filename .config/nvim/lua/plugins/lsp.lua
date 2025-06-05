return {
  {
    'williamboman/mason.nvim',
    lazy = false,
    keys = {
      { 'M', ':Mason<CR>', desc = 'Mason', silent = true },
    },
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
        'pyright',
        'ruff',
        'bashls',
        'marksman',
        'biome',
        'texlab',
        'hyprls',
      },
      automatic_installation = true,
      automatic_enable = true,
    },
  },
  {
    'neovim/nvim-lspconfig',
    lazy = false,
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

      mason_lspconfig.setup {
        ensure_installed = {
          'lua_ls',
          'clangd',
          'cmake',
          'pyright',
          'ruff',
          'bashls',
          'marksman',
          'biome',
          'texlab',
          'hyprls',
        },
        automatic_installation = true,
        automatic_enable = true,
        handlers = {
          function(server_name)
            lspconfig[server_name].setup {
              capabilities = capabilities,
            }
          end,
          lua_ls = function()
            lspconfig.lua_ls.setup { capabilities = capabilities }
          end,
          clangd = function()
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
          cmake = function()
            lspconfig.cmake.setup { capabilities = capabilities }
          end,
          pyright = function()
            lspconfig.pyright.setup { capabilities = capabilities }
          end,
          biome = function()
            lspconfig.biome.setup { capabilities = capabilities }
          end,
          marksman = function()
            lspconfig.marksman.setup { capabilities = capabilities }
          end,
          texlab = function()
            lspconfig.texlab.setup { capabilities = capabilities }
          end,
          hyprls = function()
            lspconfig.hyprls.setup { capabilities = capabilities }
          end,
        },
      }
    end,
    keys = {
      {
        'gd',
        function()
          vim.lsp.buf.definition()
        end,
        desc = 'Go To Definition',
        silent = true,
      },
      {
        'gi',
        function()
          vim.lsp.buf.implementation()
        end,
        desc = 'Go To Implementation',
        silent = true,
      },
      {
        '<leader>ca',
        function()
          vim.lsp.buf.code_action()
        end,
        desc = 'Code Actions',
        silent = true,
      },
      {
        'K',
        function()
          vim.lsp.buf.hover()
        end,
        desc = 'Hover',
        silent = true,
      },
      {
        '<leader>rn',
        function()
          vim.lsp.buf.rename()
        end,
        desc = 'Rename',
        silent = true,
      },
    },
  },
}
