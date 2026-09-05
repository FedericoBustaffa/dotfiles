return {
  {
    'stevearc/oil.nvim',
    enabled = false,
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
    'nvim-tree/nvim-tree.lua',
    lazy = false,
    enabled = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local nvimtree = require 'nvim-tree'

      local hide_root_files = false

      nvimtree.setup {
        sync_root_with_cwd = true,
        respect_buf_cwd = false,
        update_focused_file = {
          enable = true,
          update_root = false,
        },
        view = {
          side = 'left',
          width = 35,
          preserve_window_proportions = true,
        },
        actions = {
          open_file = {
            quit_on_open = false,
            resize_window = true,
          },
        },
        renderer = {
          highlight_opened_files = 'all',
        },
        git = { enable = false },
        tab = {
          sync = {
            open = false,
            close = false,
            ignore = {},
          },
        },
      }

      local keymap = vim.keymap
      keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })
      -- keymap.set('n', '<leader>e', '<cmd>NvimTreeFocus<CR>', { desc = 'Focus file explorer' })
    end,
  },
}
