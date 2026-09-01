require("vim._core.ui2").enable({})

require("options")
require("keybindings")
require("autocommands")

require("plugins.colorschemes")
require("plugins.ui")
require("plugins.utils")
require("plugins.treesitter")
require("plugins.telescope")
require("plugins.format")
require("plugins.lsp")

vim.cmd.colorscheme("tokyonight-night")
