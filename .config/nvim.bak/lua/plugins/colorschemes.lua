return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
  },
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = false,
    priority = 1000,
    opts = {
      styles = {
        bold = false,
        italic = true,
        transparency = true,
      },
    },
  },
  {
    'vague2k/vague.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      transparent = false,
      style = {
        boolean = 'none',
        number = 'none',
        float = 'none',
        error = 'none',
        comments = 'italic',
        conditionals = 'none',
        functions = 'none',
        headings = 'bold',
        operators = 'none',
        strings = 'italic',
        variables = 'none',

        -- keywords
        keywords = 'none',
        keyword_return = 'italic',
        keywords_loop = 'none',
        keywords_label = 'none',
        keywords_exception = 'none',

        -- builtin
        builtin_constants = 'none',
        builtin_functions = 'none',
        builtin_types = 'none',
        builtin_variables = 'none',
      },
    },
  },
}
