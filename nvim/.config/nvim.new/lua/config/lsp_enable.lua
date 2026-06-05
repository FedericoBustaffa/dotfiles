-- lua/config/lsp_enable.lua
-- Chiamato da init.lua DOPO il setup di lazy (e quindi dopo che blink.cmp è disponibile).

vim.lsp.enable {
  'lua_ls',
  'clangd',
  'cmake',
  'pyright',
  'bashls',
  'marksman',
  'biome',
  'texlab',
  'tinymist',
}

vim.diagnostic.config {
  virtual_text = false,
  virtual_lines = true,
  signs = true,
  underline = true,
  float = {
    border = 'rounded',
    source = true,
  },
}
