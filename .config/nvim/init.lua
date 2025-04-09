require 'config.lazy'
require 'config.options'
require 'config.keymaps'

-- highlight the yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.diagnostic.config {
    virtual_text = {
        prefix = '●',
        spacing = 2,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
}
