-- Exit normal/visual mode
vim.keymap.set({ 'i', 'v' }, '<localleader><leader>', '<ESC>', { desc = 'Exit Insert Mode', silent = true })

-- Save and turn off search highlight
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Write Buffer', silent = true })
vim.keymap.set('n', '<leader>q', function()
  local bufs = vim.fn.getbufinfo { buflisted = 1 }
  if #bufs > 1 then
    vim.cmd 'bdelete' -- Only close the current buffer
  else
    vim.cmd 'qa' -- Quit Neovim
  end
end, { desc = 'Close Buffer/Neovim', silent = true })
vim.keymap.set('n', '<ESC>', ':nohl<CR>', { silent = true })

-- Better movements
vim.keymap.set('n', 'G', 'Gzz', { silent = true })
vim.keymap.set('n', 'gg', 'ggzz', { silent = true })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { silent = true })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { silent = true })
vim.keymap.set('n', 'J', 'mzJ`z', { silent = true })
vim.keymap.set('n', 'n', 'nzzzv', { silent = true })
vim.keymap.set('n', 'N', 'Nzzzv', { silent = true })

-- Don't override on yank - paste
vim.keymap.set('x', 'p', '"_dP', { desc = 'Smart Paste', silent = true })

-- Terminal mode
vim.keymap.set('t', '<ESC>', '<C-\\><C-n>')
vim.keymap.set('n', '<localleader>tt', ':FloatTerminal<CR>i', { silent = true, desc = 'Open Float Terminal' })
vim.keymap.set('t', '<localleader>tt', '<C-\\><C-n>:FloatTerminal<CR>', { silent = true, desc = 'Close Float Terminal' })

-- Better Up and Down
vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })

-- Move to windows with Ctrl + hjkl
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move Left' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move Below' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move Above' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move Right' })

-- Resize panes
vim.keymap.set('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
vim.keymap.set('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
vim.keymap.set('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
vim.keymap.set('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })

-- Move lines
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move Lines Down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move Lines Up' })

-- Buffers
vim.keymap.set('n', '<leader>p', '<cmd>bprevious<cr>', { desc = 'Previous Buffer', silent = true })
vim.keymap.set('n', '<leader>n', '<cmd>bnext<cr>', { desc = 'Next Buffer', silent = true })

-- Lazy
vim.keymap.set('n', 'L', ':Lazy<CR>', { desc = 'Open Lazy', silent = true })

-- Source current file
vim.keymap.set('n', '<space><space>x', '<cmd>source %<CR>', { desc = 'Source Current File', silent = true })
