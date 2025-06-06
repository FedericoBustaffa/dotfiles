local blink = require 'blink.cmp'

return {
  cmd = {
    'clangd',
    '--clang-tidy',
    '--background-index',
    '--completion-style=detailed',
    '--header-insertion=never',
    '--cross-file-rename',
  },
  filetypes = { 'c', 'h', 'cpp', 'hpp' },
  root_markers = {
    'Makefile',
    'CMakeLists.txt',
    '.git',
  },
  settings = {
    clangd = {
      completion = { detailedLabel = true },
      diagnostics = true,
    },
  },
  capabilities = vim.tbl_deep_extend('force', {}, vim.lsp.protocol.make_client_capabilities(), blink.get_lsp_capabilities(), {
    fileOperations = {
      didRename = true,
      willRename = true,
    },
  }),
}
