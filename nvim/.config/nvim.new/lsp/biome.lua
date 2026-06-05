local shared = require 'lsp.shared'

vim.lsp.config('biome', {
  cmd = { 'biome', 'lsp-proxy' },
  filetypes = { 'json', 'jsonc', 'javascript', 'typescript' },
  root_markers = { 'biome.json', 'biome.jsonc', '.git' },
  on_attach = shared.on_attach,
  capabilities = shared.capabilities(),
})
