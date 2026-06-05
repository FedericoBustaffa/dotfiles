local shared = require 'lsp.shared'

vim.lsp.config('marksman', {
  cmd = { 'marksman' },
  filetypes = { 'markdown' },
  root_markers = { '.obsidian', '.git' },
  on_attach = shared.on_attach,
  capabilities = shared.capabilities(),
})
