return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  opts = {
    ensure_installed = {
      'bash',
      'doxygen',
      'markdown',
      'markdown_inline',
      'query',
      'lua',
      'luadoc',
      'vim',
      'vimdoc',
    },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
  },
}
