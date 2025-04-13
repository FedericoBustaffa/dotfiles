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
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Search Files' })
      vim.keymap.set('n', '<leader>fc', function()
        require('telescope.builtin').find_files {
          cwd = vim.fn.stdpath 'config',
        }
      end, { desc = 'Search Config Files' })
      vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = 'Search Buffers' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Grep Search' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Helper' })

      -- LSP telescope
      vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Diagnostics' })
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go To Definition' })
      vim.keymap.set('n', 'gi', builtin.lsp_implementations, { desc = 'Go To Implementation' })
      vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Search In Current Buffer' })
    end,
  },
}
