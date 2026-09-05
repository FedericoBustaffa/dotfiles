return {
  {
    'nvim-lualine/lualine.nvim',
    lazy = true,
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      theme = 'auto',
      sections = {
        lualine_x = {
          {
            require('lazy.status').updates,
            cond = require('lazy.status').has_updates,
            color = { fg = '#ff9e64' },
          },
        },
      },
    },
  },
  {
    'j-hui/fidget.nvim',
    opts = {},
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    lazy = true,
    event = 'BufReadPre',
    main = 'ibl',
    ---@module "ibl"
    ---@type ibl.config
    opts = {},
    config = function()
      require('ibl').setup {
        scope = { enabled = false },
      }
    end,
    enabled = true,
  },
  {
    'lewis6991/gitsigns.nvim',
    lazy = true,
    event = 'BufReadPre',
    opts = {
      signs = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '▎' },
        untracked = { text = '▎' },
      },
      signs_staged = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '▎' },
      },
    },
  },
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
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      animate = { enabled = true },
      bigfile = { enabled = true },
      bufdelete = { enabled = true },
      dashboard = { enabled = true },
      git = { enabled = true },
      lazygit = { enabled = true },
    },
    keys = {
      {
        '<leader>bd',
        function()
          Snacks.bufdelete()
        end,
        desc = 'Delete Buffer',
      },
      {
        '<leader>lg',
        function()
          Snacks.lazygit()
        end,
        desc = 'LazyGit',
      },
    },
  },
  {
    'akinsho/toggleterm.nvim',
    lazy = false,
    version = '*',
    opts = {
      direction = 'float',
      float_opts = {
        border = 'curved',
      },
      open_mapping = [[<A-p>]],
    },
  },
}
