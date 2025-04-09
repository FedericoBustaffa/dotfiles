require 'config.options'
require 'config.keymaps'
require 'config.autocommands'

vim.diagnostic.config {
  virtual_text = {
    prefix = '●',
    spacing = 2,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
}

vim.cmd.colorscheme 'catppuccin'
