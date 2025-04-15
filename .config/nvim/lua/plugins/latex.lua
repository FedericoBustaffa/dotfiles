return {
  'lervag/vimtex',
  lazy = true,
  ft = { 'latex', 'tex' },
  init = function()
    vim.g.vimtex_view_method = 'zathura'
  end,
}
