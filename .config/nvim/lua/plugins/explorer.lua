return {
  {
    'stevearc/oil.nvim',
    lazy = true,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      {
        '<C-e>',
        function()
          require('oil').toggle_float()
        end,
        desc = 'Open File Explorer',
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
