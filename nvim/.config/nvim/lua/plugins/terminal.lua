return {
  'akinsho/toggleterm.nvim',
  version = '*',
  opts = {
    direction = 'float',
    float_opts = {
      border = 'curved',
      width = function()
        return vim.o.columns * 0.8
      end,
    },
    open_mapping = [[<A-p>]],
  },
}
