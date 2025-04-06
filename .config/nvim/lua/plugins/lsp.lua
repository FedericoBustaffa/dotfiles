return {
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
      require('lspconfig').lua_ls.setup { capabilities = capabilities }
      require('lspconfig').clangd.setup {
        capabilities = capabilities,
        cmd = {
          'clangd',
          '--clang-tidy',
          '--background-index',
          '--completion-style=detailed',
          '--header-insertion=never',
        },
      }
      require('lspconfig').pyright.setup {
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
    end,
  },
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup {
        ensure_installed = {
          'lua-language-server',
          'clang-format',
          'black',
          'isor',
        },
      }
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = {
          'clangd',
          'pyright',
        },
        automatic_installation = true,
      }
    end,
  },
}
