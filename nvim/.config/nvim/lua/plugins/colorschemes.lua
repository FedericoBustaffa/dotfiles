return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
  },
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = false,
    priority = 1000,
    opts = {
      variant = 'main',
      dark_variant = 'main',
      styles = {
        bold = false,
        italic = true,
        transparency = false,
      },
    },
  },
  {
    'dgox16/oldworld.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'vague-theme/vague.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'smit4k/shale.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'AlexvZyl/nordic.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    '54L1M/Oshen.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('oshen').setup {
        transparent = false, -- set false for opaque background
      }
    end,
  },
}
