return {
  {
    'echasnovski/mini.nvim',
    lazy = true,
    version = '*',
    config = function()
      require('mini.icons').setup()
    end,
  },
}
