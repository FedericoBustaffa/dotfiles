local blink = require 'blink.cmp'

return {
  filetypes = { 'conf' },
  root_markers = { '.hypr', 'hyprland.conf' },
  capabilities = vim.tbl_deep_extend('force', {}, vim.lsp.protocol.make_client_capabilities(), blink.get_lsp_capabilities(), {
    fileOperations = {
      didRename = true,
      willRename = true,
    },
  }),
}
