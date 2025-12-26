local blink = require 'blink.cmp'

return {
  cmd = {
    'hyprls',
  },
  -- filetypes = { '' },
  root_dir = '~/.config/hypr/',
  settings = {
    hyprls = {
      preferIgnoreFile = true, -- set to false to prefer `hyprls.ignore`
      ignore = { 'hyprlock.conf', 'hypridle.conf' },
    },
  },
  capabilities = vim.tbl_deep_extend('force', {}, vim.lsp.protocol.make_client_capabilities(), blink.get_lsp_capabilities(), {
    fileOperations = {
      didRename = true,
      willRename = true,
    },
  }),
}
