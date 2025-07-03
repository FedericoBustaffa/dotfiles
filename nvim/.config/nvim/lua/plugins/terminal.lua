return {
  'nvzone/floaterm',
  dependencies = 'nvzone/volt',
  lazy = false,
  opts = {
    border = false,
    size = { h = 70, w = 80 },

    -- to use, make this func(buf)
    mappings = { sidebar = nil, term = nil },

    -- Default sets of terminals you'd like to open
    terminals = {
      { name = 'Terminal' },
    },
  },
  cmd = 'FloatermToggle',
  keys = {
    {
      '<localleader>tt',
      ':FloatermToggle<CR>',
      desc = 'Toggle floating terminal',
      silent = true,
    },
    {
      '<localleader>tt',
      '<C-\\><C-n>:FloatermToggle<CR>',
      mode = 't',
      desc = 'Toggle floating terminal',
      silent = true,
    },
  },
}
