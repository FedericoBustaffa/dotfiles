local blink = require 'blink.cmp'

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, blink.get_lsp_capabilities() or {})

capabilities.workspace = capabilities.workspace or {}
capabilities.workspace.fileOperations = {
  didRename = true,
  willRename = true,
}

return {
  filetypes = { 'sh', 'bash' },
  settings = {
    bash = { -- attenzione: non 'bashls'
      completion = { detailedLabel = true },
      diagnostics = true,
    },
  },
  capabilities = capabilities,
}
