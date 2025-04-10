return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  main = 'nvim-treesitter.configs',
  opts = {
    ensure_installed = {
      'bash',
      'c',
      'cpp',
      'make',
      'cmake',
      'python',
      'lua',
      'vim',
      'vimdoc',
      'json',
    },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
  },
}
