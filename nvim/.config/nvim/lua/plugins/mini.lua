return {
  {
    'echasnovski/mini.nvim',
    lazy = true,
    version = '*',
    config = function()
      require('mini.icons').setup()
    end,
  },
  {
    'echasnovski/mini.notify',
    opts = {
      window = {
        config = {},
        max_width_share = 0.5,
      },
    },
  },
}
