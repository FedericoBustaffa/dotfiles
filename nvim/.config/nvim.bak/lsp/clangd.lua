return {
  cmd = {
    'clangd',
    '--clang-tidy',
    '--background-index=true',
    '--completion-style=detailed',
    '--header-insertion=never',
    '--cross-file-rename',
  },

  filetypes = { 'c', 'h', 'cpp', 'hpp' },

  root_markers = {
    'Makefile',
    'CMakeLists.txt',
    '.git',
  },

  init_options = {
    fallbackFlags = {
      '-std=c++23',
    },
  },

  settings = {
    clangd = {
      completion = { detailedLabel = true },
      diagnostics = true,
    },
  },
}
