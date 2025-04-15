return {
  'nvim-treesitter/nvim-treesitter',
  lazy = true,
  event = 'BufReadPre',
  build = ':TSUpdate',
  main = 'nvim-treesitter.configs',
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
