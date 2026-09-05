return {
  {
    'folke/lazydev.nvim',
    lazy = true,
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'saghen/blink.cmp',
    lazy = false,
    dependencies = {
      'saghen/blink.lib',
      'rafamadriz/friendly-snippets',
      'folke/lazydev.nvim',
    },
    build = 'cargo build --release',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = 'default' },

      signature = { enabled = true },

      completion = {
        trigger = {
          show_on_insert = true,
          show_on_trigger_character = true,
          show_on_keyword = true,
          show_on_backspace = true,
        },
        list = {
          selection = {
            preselect = false,
            auto_insert = true,
          },
        },
        menu = {
          border = 'single',
          scrolloff = 1,
          draw = {
            columns = {
              { 'kind_icon' },
              { 'label', 'label_description', gap = 1 },
              { 'kind' },
              { 'source_name' },
            },
          },
        },
        documentation = {
          window = { border = 'single' },
          auto_show = false,
        },
      },

      sources = {
        default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
        },
      },

      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = 'mono',
      },

      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
  },
}
