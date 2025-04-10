return {
  {
    'stevearc/oil.nvim',
    dependencies = {
      { 'echasnovski/mini.icons', opts = {} },
      -- { "nvim-tree/nvim-web-devicons" }
    },
    lazy = false,
    keys = {
      { '-', '<cmd>Oil<CR>', desc = 'Opens Oil file explorer' },
      {
        '<C-e>',
        function()
          require('oil').toggle_float()
        end,
      },
    },
    opts = {
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        ['q'] = { 'actions.close', mode = 'n' },
      },
    },
  },
}
