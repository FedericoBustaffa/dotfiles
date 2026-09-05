return {
  {
    'folke/which-key.nvim',
    lazy = true,
    event = 'VeryLazy',
    opts = {},
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show { global = false }
        end,
        desc = 'Buffer Local Keymaps (which-key)',
      },
    },
  },
  {
    'windwp/nvim-autopairs',
    lazy = true,
    event = 'InsertEnter',
    opts = {},
  },
  {
    'christoomey/vim-tmux-navigator',
    lazy = false,
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
      'TmuxNavigatorProcessList',
    },
    keys = {
      { '<C-h>', '<CMD>TmuxNavigateLeft<CR>' },
      { '<C-j>', '<CMD>TmuxNavigateDown<CR>' },
      { '<C-k>', '<CMD>TmuxNavigateUp<CR>' },
      { '<C-l>', '<CMD>TmuxNavigateRight<CR>' },
    },
  },
}
