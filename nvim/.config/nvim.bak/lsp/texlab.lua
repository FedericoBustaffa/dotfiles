return {
  filetypes = { 'tex', 'latex' },
  root_markers = { '.git' },
  settings = {
    texlab = {
      build = { onSave = true },
      diagnostics = true,
    },
  },
}
