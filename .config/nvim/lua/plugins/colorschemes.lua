return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        flavour = 'mocha',
        transparent_background = true,
        integrations = {
          -- tutto quello che usi, per esempio:
          cmp = true,
          gitsigns = true,
          telescope = true,
          treesitter = true,
          native_lsp = {
            enabled = true,
          },
        },
      }
    end,
  },
  {
    'folke/tokyonight.nvim',
    name = 'tokyonight',
    lazy = false,
    priority = 1000,
  },
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = false,
    priority = 1000,
  },
  {
    'Mofiqul/vscode.nvim',
    lazy = false,
    priority = 1000,
  },
}
