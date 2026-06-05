local vim_capabilities = vim.lsp.protocol.make_client_capabilities()
local blink_capabilities = require('blink.cmp').get_lsp_capabilities()
local capabilities = vim.tbl_deep_extend('force', vim_capabilities, blink_capabilities)

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
  capabilities = capabilities,
})

vim.lsp.enable {
  'lua_ls',
  'clangd',
  -- 'cmake',
  'neocmake',
  'pyright',
  -- 'basedpyright',
  -- 'ty',
  'bashls',
  'marksman',
  'biome',
  'bashls',
  'shellcheck',
  'texlab',
  'tinymist',
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
    'neovim/nvim-lspconfig',
  },
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
        -- 'cmake',
        'neocmake',
        'pyright',
        -- 'basedpyright',
        -- 'ty',
        'ruff',
        'bashls',
        'marksman',
        'biome',
        'bashls',
        'texlab',
        'tinymist',
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
