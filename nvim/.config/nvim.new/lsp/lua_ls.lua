local shared = require 'lsp.shared'

vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.stylua.toml', 'stylua.toml', '.git' },
  on_attach = shared.on_attach,
  capabilities = shared.capabilities(),
  settings = {
    Lua = {
      diagnostics = {
        disable = { 'missing-fields' },
        globals = { 'vim', 'Snacks' },
      },
      hint = {
        enable = true,
        setType = false,
        paramType = true,
        paramName = 'Disable',
        semicolon = 'Disable',
        arrayIndex = 'Disable',
      },
    },
  },
})
