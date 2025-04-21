return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    lazy = true,
    ft = 'markdown',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      completions = { blink = { enabled = true } },
      latex = { enabled = false },
      render_modes = { 'n', 'c', 't' },
    },
  },
  {
    'brianhuster/live-preview.nvim',
    lazy = true,
    ft = 'markdown',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    opts = {},
    keys = {
      { '<localleader>mm', ':LivePreview start<CR>', desc = 'Start Markdown Preview' },
      { '<localleader>mc', ':LivePreview close<CR>', desc = 'Close Markdown Preview' },
    },
  },
}
