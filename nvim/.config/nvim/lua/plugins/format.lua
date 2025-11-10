return {
  {
    'nvimtools/none-ls.nvim',
    lazy = true,
    event = 'VeryLazy',
    config = function()
      require('null-ls').setup {}
    end,
  },
  {
    'jay-babu/mason-null-ls.nvim',
    lazy = true,
    event = 'VeryLazy',
    dependecies = {
      'williamboman/mason.nvim',
      'nvimtools/none-ls.nvim',
    },
    config = function()
      require('mason-null-ls').setup {
        ensure_installed = {
          'stylua',
          'clang-format',
          'beautysh',
          'cmakelang',
          'markdownlint',
          'prettierd',
          'latexindent',
        },
        automatic_installation = true,
      }
    end,
  },
  {
    'stevearc/conform.nvim',
    lazy = true,
    event = 'BufWritePre',
    dependencies = {
      'jay-babu/mason-null-ls.nvim',
      'nvimtools/none-ls.nvim',
    },
    config = function()
      require('conform').setup {
        formatters_by_ft = { -- specify the extension
          lua = { 'stylua' },
          c = { 'clang-format' },
          cpp = { 'clang-format' },
          python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
          json = { 'biome' },
          sh = { 'beautysh' },
          bash = { 'beautysh' },
          zsh = { 'beautysh' },
          markdown = { 'prettierd' },
          latex = { 'latexindent' },
          typst = { 'typstyle' },
        },
        format_on_save = {
          lsp_fallback = true,
          timeout_ms = 1000,
        },
      }
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then
            return
          end

          if client.supports_method(client, 'textDocument/formatting') then
            vim.api.nvim_create_autocmd('BufWritePre', {
              buffer = args.buf,
              callback = function()
                require('conform').format { bufnr = args.buf, id = client.id }
              end,
            })
          end
        end,
      })
    end,
  },
}
