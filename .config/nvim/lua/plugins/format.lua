return {
  {
    'stevearc/conform.nvim',
    config = function()
      require('conform').setup {
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'isort', 'black' },
          cpp = { 'clang-format' },
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

          if client.supports_method(client, 'textDocument/formatting', 0) then
            vim.api.nvim_create_autocmd('BufWritePre', {
              buffer = args.buf,
              callback = function()
                -- vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
                require('conform').format { bufnr = args.buf, id = client.id }
              end,
            })
          end
        end,
      })
    end,
  },
}
