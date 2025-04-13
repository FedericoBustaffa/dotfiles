return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    build = 'make',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      { 'nvim-telescope/telescope-ui-select.nvim' },
    },
    config = function()
      require('telescope').setup {
        pickers = {
          find_files = {
            -- theme = 'default',
            -- hidden = true,
          },
          -- diagnostics = {
          --   theme = 'default',
          -- },
        },
        extensions = {
          fzf = {},
          ['ui-select'] = {
            require('telescope.themes').get_dropdown {},
          },
        },
      }

      -- enable fzf
      require('telescope').load_extension 'fzf'
      require('telescope').load_extension 'ui-select'

      -- Key Bindings
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sf', builtin.find_files)
      vim.keymap.set('n', '<leader>en', function()
        require('telescope.builtin').find_files {
          cwd = vim.fn.stdpath 'config',
        }
      end)
      vim.keymap.set('n', '<leader>sb', builtin.buffers)
      vim.keymap.set('n', '<leader>sg', builtin.live_grep)
      vim.keymap.set('n', '<leader>sh', builtin.help_tags)

      -- LSP telescope
      vim.keymap.set('n', 'ga', builtin.diagnostics)
      vim.keymap.set('n', 'gd', builtin.lsp_definitions)
      vim.keymap.set('n', 'gi', builtin.lsp_implementations)
    end,
  },
}
