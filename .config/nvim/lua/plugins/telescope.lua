return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    build = 'make',
    lazy = true,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['fzf'] = {},
          ['ui-select'] = {},
        },
      }
      require('telescope').load_extension 'fzf'
      require('telescope').load_extension 'ui-select'
    end,
    keys = {
      {
        '<leader>ff',
        function()
          require('telescope.builtin').find_files()
        end,
        desc = 'Find Files',
      },
      {
        '<leader>fc',
        function()
          require('telescope.builtin').find_files {
            cwd = vim.fn.stdpath 'config',
          }
        end,
        desc = 'Find Config Files',
      },
      {
        '<leader>fb',
        function()
          require('telescope.builtin').buffers()
        end,
        desc = 'Find Buffers',
      },
      {
        '<leader>/',
        function()
          require('telescope.builtin').current_buffer_fuzzy_find()
        end,
        desc = 'Search In Current Buffer',
      },
      {
        '<leader>fg',
        function()
          require('telescope.builtin').live_grep()
        end,
        desc = 'Grep Find',
      },
      {
        '<leader>fh',
        function()
          require('telescope.builtin').help_tags()
        end,
        desc = 'Find Help',
      },

      -- -- LSP telescope
      {
        '<leader>D',
        function()
          require('telescope.builtin').diagnostics()
        end,
        desc = 'Diagnostics',
      },
      {
        '<leader>fs',
        function()
          require('telescope.builtin').lsp_document_symbols()
        end,
        desc = 'Find Document Symbols',
      },
    },
  },
}
