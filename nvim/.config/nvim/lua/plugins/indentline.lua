return {
  'lukas-reineke/indent-blankline.nvim',
  lazy = true,
  event = 'BufReadPre',
  main = 'ibl',
  ---@module "ibl"
  ---@type ibl.config
  opts = {},
  config = function()
    require('ibl').setup {

      scope = { enabled = false },
    }
  end,
  enabled = true,
}
