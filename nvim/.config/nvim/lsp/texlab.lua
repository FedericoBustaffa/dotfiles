local shared = require 'lsp.shared'

vim.lsp.config('texlab', {
  cmd = { 'texlab' },
  filetypes = { 'tex', 'latex' },
  root_markers = { '.git' },
  on_attach = shared.on_attach,
  capabilities = shared.capabilities(),
  settings = {
    texlab = {
      build = { onSave = true },
    },
  },
})
