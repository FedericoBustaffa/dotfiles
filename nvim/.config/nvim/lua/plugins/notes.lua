return {
  { -- In editor markdown live rendering
    'MeanderingProgrammer/render-markdown.nvim',
    enabled = true,
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
    'brianhuster/live-preview.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
  },
  -- { -- Live preview of markdown
  --   'iamcco/markdown-preview.nvim',
  --   lazy = true,
  --   ft = 'markdown',
  --   cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  --   build = 'cd app && yarn install',
  --   init = function()
  --     vim.g.mkdp_filetypes = { 'markdown' }
  --     vim.g.mkdp_theme = 'light'
  --   end,
  --   keys = {
  --     { '<localleader>mm', ':MarkdownPreviewToggle<CR>', desc = 'Markdown Preview' },
  --   },
  -- },
  {
    'epwalsh/obsidian.nvim',
    version = '*',
    lazy = true,
    ft = 'markdown',
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
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
    lazy = true,
    ft = { 'latex', 'tex' },
    init = function()
      vim.g.vimtex_view_method = 'zathura'
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
    enabled = true,
    lazy = true,
    ft = 'typst',
    version = '1.*',
    opts = {},
    keys = {
      { '<localleader>ty', ':TypstPreview<CR>', desc = 'Typst Preview' },
    },
  },
}
