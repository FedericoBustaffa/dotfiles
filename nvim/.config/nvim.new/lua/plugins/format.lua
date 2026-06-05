return {
  -- mason-tool-installer: installa i formatter/linter via mason
  -- (sostituisce mason-null-ls ora che none-ls è rimosso)
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    lazy = false,
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      ensure_installed = {
        'stylua',
        'clang-format',
        'beautysh',
        'shellcheck',
        'cmakelang',
        'markdownlint',
        'prettierd',
        'latexindent',
        'typstyle',
        'ruff',
      },
      auto_update = false,
      run_on_start = true,
    },
  },

  -- conform.nvim: formatting on save
  {
    'stevearc/conform.nvim',
    lazy = true,
    event = 'BufWritePre',
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        python = { 'ruff_format', 'ruff_organize_imports' },
        json = { 'biome' },
        jsonc = { 'biome' },
        bash = { 'beautysh' },
        sh = { 'beautysh' },
        zsh = { 'beautysh' },
        markdown = { 'prettierd' },
        latex = { 'latexindent' },
        tex = { 'latexindent' },
        typst = { 'typstyle' },
      },
      format_on_save = {
        timeout_ms = 1000,
        lsp_format = 'fallback', -- usa LSP solo se nessun formatter è definito per il filetype
      },
    },
  },
}
