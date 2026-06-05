local shared = require 'lsp.shared'

vim.lsp.config('tinymist', {
  cmd = { 'tinymist' },
  filetypes = { 'typst' },
  root_markers = { '.git' },
  on_attach = shared.on_attach,
  capabilities = shared.capabilities(),
})
