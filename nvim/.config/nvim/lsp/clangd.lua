local shared = require 'lsp.shared'

vim.lsp.config('clangd', {
  cmd = {
    'clangd',
    '--clang-tidy',
    '--background-index=true',
    '--completion-style=detailed',
    '--header-insertion=never',
    '--cross-file-rename',
  },
  filetypes = { 'c', 'cpp', 'h', 'hpp' },
  root_markers = { 'compile_commands.json', 'CMakeLists.txt', 'Makefile', '.git' },
  on_attach = shared.on_attach,
  capabilities = shared.capabilities(),
})
