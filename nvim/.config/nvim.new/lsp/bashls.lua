local shared = require 'lsp.shared'

vim.lsp.config('bashls', {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'sh', 'bash' },
  root_markers = { '.git' },
  on_attach = shared.on_attach,
  capabilities = shared.capabilities(),
})
