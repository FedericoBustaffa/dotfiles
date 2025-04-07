vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

vim.keymap.set('i', '<localleader><leader>', '<ESC>')
vim.keymap.set('v', '<localleader><leader>', '<ESC>')

vim.keymap.set('n', '<leader>w', ':w<CR>')
vim.keymap.set('n', '<leader>q', ':q<CR>')
vim.keymap.set('n', '<ESC>', ':nohl<CR>')

vim.keymap.set('n', 'G', 'Gzz')

-- Terminal mode
vim.keymap.set('t', '<ESC>', '<C-\\><C-n>')
vim.keymap.set('n', 'tt', ':FloatTerminal<CR>i')
vim.keymap.set('t', 'tt', '<C-\\><C-n>:FloatTerminal<CR>')
