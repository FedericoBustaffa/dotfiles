return {
  cmd = { 'cmake-language-server' },
  filetypes = { 'cmake' },
  root_markers = { 'CMakeLists.txt', '.git' },
  single_file_support = true,
  init_options = {
    buildDirectory = 'build',
  },
}
