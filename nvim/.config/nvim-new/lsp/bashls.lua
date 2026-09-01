return {
  filetypes = { 'sh', 'bash' },
  settings = {
    bash = { -- attenzione: non 'bashls'
      completion = { detailedLabel = true },
      diagnostics = true,
    },
  },
}
