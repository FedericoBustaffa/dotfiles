vim.lsp.config('*', {
  on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, silent = true }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  end,
})

vim.lsp.enable {
  'lua_ls',
  'clangd',
  'cmake',
  'pyright',
  'bashls',
  'marksman',
  'biome',
  'texlab',
}

vim.diagnostic.config {
  virtual_text = false,
  virtual_lines = true,
  signs = true,
  underline = true,
  float = {
    border = 'rounded',
    source = true,
  },
}

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
      },
      automatic_installation = true,
    },
  },
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
