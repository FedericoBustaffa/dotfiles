return {
  {
    'echasnovski/mini.nvim',
    version = '*',
    config = function()
      require('mini.icons').setup()
      require('mini.git').setup()
      require('mini.diff').setup()
      require('mini.pairs').setup()
      -- require('mini.statusline').setup()
      -- require('mini.indentscope').setup { symbol = '|' }
    end,
  },
}
