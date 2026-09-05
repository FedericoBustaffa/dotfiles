return {
  'nvim-telescope/telescope.nvim',
  build = 'make',
  lazy = true,
  dependencies = {
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-symbols.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    'nvim-telescope/telescope-file-browser.nvim',
    '2kabhishek/nerdy.nvim',
  },
  config = function()
    local actions = require 'telescope.actions'
    require('telescope').setup {
      defaults = {
        file_ignore_patterns = {
          '%.jpg',
          '%.jpeg',
          '%.png',
          '%.svg',
          '%.gif',
          '%.webp',
          '%.pdf',
          '%.zip',
          'build/',
          '.cache/',
          '%.git/',
          '%.obsidian/',
          '%.egg-info/*',
          '.git/',
          '.venv',
          '.node_modules',
          'node_modules',
          '.svelte-kit',
          '.vscode',
        },
      },
      pickers = {
        buffers = {
          show_all_buffers = true,
          mappings = {
            i = { ['<CR>'] = actions.select_drop },
            n = { ['<CR>'] = actions.select_drop, ['d'] = actions.delete_buffer },
          },
        },
        find_files = {
          show_all_buffers = true,
          mappings = {
            i = { ['<CR>'] = actions.select_drop },
            n = { ['<CR>'] = actions.select_drop },
          },
        },
        live_grep = {
          additional_args = function()
            return { '--hidden' }
          end,
        },
      },
      extensions = {
        file_browser = {
          theme = 'ivy',
          hijack_netrw = true,
        },
        ['fzf'] = {},
        ['ui-select'] = {
          require('telescope.themes').get_dropdown {},
        },
      },
    }
    require('telescope').load_extension 'fzf'
    require('telescope').load_extension 'file_browser'
    require('telescope').load_extension 'ui-select'
    require('telescope').load_extension 'nerdy'
  end,
  keys = {
    {
      '<leader>ff',
      function()
        local builtin = require 'telescope.builtin'
        builtin.find_files { hidden = true }
      end,
      desc = 'Find Files',
    },
    {
      '<leader>e',
      function()
        require('telescope').extensions.file_browser.file_browser()
      end,
      desc = 'File Browser Root Dir',
    },
    {
      '<leader>fn',
      function()
        local full_path = vim.api.nvim_buf_get_name(0)
        local dir = vim.fn.fnamemodify(full_path, ':h')
        require('telescope').extensions.file_browser.file_browser {
          path = dir,
        }
      end,
      desc = 'File Browser Current Dir',
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
      '<leader>fg',
      function()
        require('telescope.builtin').live_grep { hidden = true }
      end,
      desc = 'Grep Find',
    },
    {
      '<leader>fb',
      function()
        require('telescope.builtin').buffers { show_all_buffers = true }
      end,
      desc = 'Find Buffers',
    },
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
    {
      '<leader>fws',
      function()
        require('telescope.builtin').lsp_workspace_symbols()
      end,
      desc = 'Find Workspace Symbols',
    },
    {
      '<leader>fh',
      function()
        require('telescope.builtin').help_tags()
      end,
      desc = 'Find Help',
    },
  },
}
