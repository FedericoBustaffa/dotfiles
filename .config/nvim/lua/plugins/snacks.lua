return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    animate = { enabled = true },
    bigfile = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    bufdelete = { enabled = true },
    dashboard = { enabled = true },
    git = { enabled = true },
    lazygit = { enabled = true },
  },
  keys = {
    {
      '<leader>bd',
      function()
        Snacks.bufdelete()
      end,
      desc = 'Delete Buffer',
    },
    {
      '<leader>lg',
      function()
        Snacks.lazygit()
      end,
      desc = 'LazyGit',
    },
  },
}
