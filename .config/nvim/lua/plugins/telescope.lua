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
          find_files = {},
        },
        extensions = {
          ['fzf'] = {},
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

      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
      vim.keymap.set('n', '<leader>fc', function()
        require('telescope.builtin').find_files {
          cwd = vim.fn.stdpath 'config',
        }
      end, { desc = 'Find Config Files' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find Buffers' })
      vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Search In Current Buffer' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Grep Find' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find Help' })

      -- LSP telescope
      vim.keymap.set('n', '<leader>D', builtin.diagnostics, { desc = 'Diagnostics' })
      vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Find Document Symbols' })
    end,
  },
}
