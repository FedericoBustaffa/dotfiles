return {
  {
    'nvim-lualine/lualine.nvim',
    lazy = true,
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        sections = {
          lualine_x = {
            {
              require('lazy.status').updates,
              cond = require('lazy.status').has_updates,
              color = { fg = '#ff9e64' },
            },
            {
              require('noice').api.statusline.mode.get,
              cond = require('noice').api.statusline.mode.has,
              color = { fg = '#ff9e64' },
            },
          },
        },
      }
    end,
  },
  {
    'j-hui/fidget.nvim',
    opts = {},
  },
}
