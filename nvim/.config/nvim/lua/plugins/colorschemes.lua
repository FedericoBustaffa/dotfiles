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
      disable_background = false,
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
    'vague-theme/vague.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'oskarnurm/koda.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'wtfox/luna.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      transparent = false,
    },
  },
  {
    'wtfox/jellybeans.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    'tadaa/vimade',
    lazy = false,
    opts = {
      recipe = { 'minimalist', { animate = true } },
      fadelavel = 0.95,
    },
  },
}
