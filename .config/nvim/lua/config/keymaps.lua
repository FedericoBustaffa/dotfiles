-- Exit normal/visual mode
vim.keymap.set('i', '<localleader><leader>', '<ESC>', { desc = 'Exit Insert Mode' })
vim.keymap.set('v', '<localleader><leader>', '<ESC>', { desc = 'Exit Visual Mode' })

-- Save and turn off search highlight
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Write Buffer' })
vim.keymap.set('n', '<ESC>', ':nohl<CR>', { silent = true })

-- Better G
vim.keymap.set('n', 'G', 'Gzz')

-- Terminal mode
vim.keymap.set('t', '<ESC>', '<C-\\><C-n>')
vim.keymap.set('n', 'tt', ':FloatTerminal<CR>i', { silent = true, desc = 'Open Float Terminal' })
vim.keymap.set('t', 'tt', '<C-\\><C-n>:FloatTerminal<CR>', { silent = true, desc = 'Close Float Terminal' })

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
vim.keymap.set('n', '<A-j>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move Down' })
vim.keymap.set('n', '<A-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move Up' })
vim.keymap.set('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move Down' })
vim.keymap.set('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move Up' })
vim.keymap.set('v', '<A-j>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = 'Move Down' })
vim.keymap.set('v', '<A-k>', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = 'Move Up' })

-- Buffers
vim.keymap.set('n', '<leader>p', '<cmd>bprevious<cr>', { desc = 'Previous Buffer' })
vim.keymap.set('n', '<leader>n', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
vim.keymap.set('n', '<leader>q', '<cmd>bdelete<cr>', { desc = 'Close Buffer' })

-- Lazy
vim.keymap.set('n', 'L', ':Lazy<CR>', { desc = 'Open Lazy' })
vim.keymap.set('n', 'M', ':Mason<CR>', { desc = 'Open Mason' })

-- Source current file
vim.keymap.set('n', '<space><space>x', '<cmd>source %<CR>')
