return {
  {
    'stevearc/conform.nvim',
    lazy = true,
    event = 'BufWritePre',
    config = function()
      require('conform').setup {
        formatters_by_ft = { -- specify the extension
          lua = { 'stylua' },
          c = { 'clang-format' },
          cpp = { 'clang-format' },
          python = { 'ruff_format', 'ruff_organize_imports' },
          json = { 'biome' },
          bash = { 'beautysh' },
          sh = { 'beautysh', 'shellcheck' },
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
  {
    'mfussenegger/nvim-lint',
    lazy = true,
    event = 'BufWritePre',
    config = function()
      local lint = require 'lint'
      vim.api.nvim_create_autocmd('BufWritePost', {
        callback = function()
          local ft = vim.bo.filetype
          if lint.linters_by_ft[ft] then
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
