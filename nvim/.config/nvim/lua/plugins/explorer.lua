return {
  {
    'stevearc/oil.nvim',
    lazy = true,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      {
        '<leader>e',
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
    },
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    enabled = false,
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons', -- optional, but recommended
    },
    lazy = false, -- neo-tree will lazily load itself
    keys = {
      {
        '<leader>e',
        function()
          require('neotree').toggle()
        end,
        desc = 'Open File Explorer',
      },
    },
  },
}
