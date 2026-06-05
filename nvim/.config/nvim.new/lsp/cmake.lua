local shared = require 'lsp.shared'

vim.lsp.config('cmake', {
  cmd = { 'cmake-language-server' },
  filetypes = { 'cmake' },
  root_markers = { 'CMakeLists.txt', '.git' },
  on_attach = shared.on_attach,
  capabilities = shared.capabilities(),
  init_options = { buildDirectory = 'build' },
})
