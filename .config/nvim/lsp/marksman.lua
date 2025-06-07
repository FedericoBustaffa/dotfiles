local blink = require 'blink.cmp'

return {
  cmd = {
    'marksman',
  },
  filetypes = { 'md', 'markdown' },
  root_markers = {
    '.obsidian',
    '.git',
  },
  settings = {
    marksman = {
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
