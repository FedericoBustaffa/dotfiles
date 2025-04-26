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
      code = {
        border = 'thin',
      },
    },
  },
  {
    'iamcco/markdown-preview.nvim',
    lazy = true,
    ft = 'markdown',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
      vim.g.mkdp_theme = 'light'
    end,
    keys = {
      { '<localleader>mm', ':MarkdownPreviewToggle<CR>', desc = 'Markdown Preview' },
    },
  },
}
