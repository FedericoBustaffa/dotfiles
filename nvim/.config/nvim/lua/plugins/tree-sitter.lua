return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'master',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup {
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
      additional_vim_regex_highlighting = false,
    }
  end,
}
