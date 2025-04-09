return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    event = 'VeryLazy',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'cpp',
        'python',
        'lua',
        'vim',
        'vimdoc',
        'query',
        'json',
      },

      sync_install = false,
      auto_install = false,

      highlight = {
        enable = true,
      },
      indent = { enable = true, disable = {} },
    },
  },
}
