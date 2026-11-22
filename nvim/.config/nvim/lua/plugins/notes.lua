return {
  {
    'OXY2DEV/markview.nvim',
    enabled = false,
    lazy = false,
    dependencies = { 'saghen/blink.cmp' },
  },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
  },
  {
    'epwalsh/obsidian.nvim',
    enabled = false,
    version = '*',
    lazy = true,
    ft = 'markdown',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      workspaces = {
        {
          name = 'obsidian',
          path = '~/obsidian/',
        },
      },
    },
  },
  { -- LaTeX
    'lervag/vimtex',
    enabled = true,
    lazy = true,
    ft = { 'latex', 'tex' },
    init = function()
      vim.g.vimtex_view_method = 'sioyek'
      vim.g.vimtex_compiler_latexmk = {
        backend = 'nvim',
        build_dir = '',
        callback = 1,
        continuous = 1,
        executable = 'latexmk',
        options = {
          '-pdf',
          '-shell-escape',
          '-interaction=nonstopmode',
          '-synctex=1',
        },
      }
    end,
  },
  { -- Typst
    'chomosuke/typst-preview.nvim',
    enabled = false,
    lazy = true,
    ft = 'typst',
    version = '1.*',
    opts = {},
    keys = {
      { '<localleader>ty', ':TypstPreviewToggle<CR>', desc = 'Typst Preview' },
    },
  },
}
