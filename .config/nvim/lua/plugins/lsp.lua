return {
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup {
        ui = {
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗',
          },
        },
      }

      -- install tools se non presenti
      local mason_registry = require 'mason-registry'
      local tools = {
        'stylua',
        'black',
        'isort',
        'ruff',
        'clang-format',
        'beautysh',
        'checkmake',
        'biome',
      }

      for _, tool in ipairs(tools) do
        local p = mason_registry.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = {
          'lua_ls',
          'clangd',
          'pyright',
          'pylsp',
          'bashls',
          'biome',
        },
        automatic_installation = true,
      }
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'saghen/blink.cmp',
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
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      local lspconfig = require 'lspconfig'
      lspconfig.lua_ls.setup { capabilities = capabilities }
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
      lspconfig.pyright.setup {
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = 'basic', -- oppure "strict"
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      }
      lspconfig.biome.setup { capabilities = capabilities }
    end,
  },
}
