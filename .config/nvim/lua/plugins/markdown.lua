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
      completions = {
        blink = { enabled = true },
      },
    },
    enabled = false,
  },
  {
    'iamcco/markdown-preview.nvim',
    ft = { 'markdown' },
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    keys = {
      { '<localleader>mm', ':MarkdownPreviewToggle<CR>', desc = 'Toggle Markdown Preview' },
    },
  },
}
