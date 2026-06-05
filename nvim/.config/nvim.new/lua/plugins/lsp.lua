return {
  -- Mason: installa i binari
  {
    'williamboman/mason.nvim',
    lazy = false,
    keys = {
      { 'M', ':Mason<CR>', desc = 'Mason', silent = true },
    },
    opts = {
      ui = {
        icons = {
          package_installed = '✓',
          package_pending = '➜',
          package_uninstalled = '✗',
        },
      },
    },
  },

  -- mason-lspconfig: installa i server LSP tramite mason
  -- NON configura più nulla — solo ensure_installed
  {
    'williamboman/mason-lspconfig.nvim',
    lazy = false,
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      ensure_installed = {
        'lua_ls',
        'clangd',
        'cmake',
        'pyright',
        'bashls',
        'marksman',
        'biome',
        'texlab',
        'tinymist',
      },
      -- NON usare automatic_enable: la configurazione è gestita da vim.lsp.config
      automatic_enable = false,
    },
  },

  -- lazydev: LuaLS migliorato per editare la config di Neovim
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
}
