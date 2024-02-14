" general setup
filetype plugin indent on
syntax on

set nocompatible
set encoding=UTF-8
set tabstop=4
set shiftwidth=4
set autoindent
set smartindent
set number
set relativenumber
set mouse=a
set hlsearch
set incsearch
set hidden
set fdm=indent
set foldlevelstart=99
set ignorecase
set smartcase
set splitbelow
set splitright
set completeopt-=preview

" --- KEY BINDINGS ---
" LEADERS
let mapleader = " "
let maplocalleader = "\\"


" --- NORMAL MODE ---
" open config file in a new tab
nnoremap <leader>ev :e $MYVIMRC<CR>

" reload config file
nnoremap <leader>sv :source $MYVIMRC<CR>

" Delete to the end of the line
nnoremap <leader>de d$

" Centering after jump to the end of the file
nnoremap G Gzz

" navigate between buffers
nnoremap <leader><Left> :bprevious<CR>
nnoremap <leader><Right> :bnext<CR>
nnoremap <leader>gg :bfirst<CR>
nnoremap <leader>G :blast<CR>

" switch panes with arrows
nnoremap <C-Left> <C-w>h
nnoremap <C-Right> <C-w>l
nnoremap <C-Down> <C-w>j
nnoremap <C-Up> <C-w>k

" show all buffers and let user choose one 
nnoremap <leader>i :ls<CR>:b<Space>

" delete current buffer
nnoremap <leader>dd :bd<CR>

" write current buffer
nnoremap <leader>w :write<CR>

" navigate between buffers
nnoremap <leader><tab> <C-^>

" move one line up and down
nnoremap <A-Down> :m .+1<CR>==
nnoremap <A-Up> :m .-2<CR>==


" --- INSERT MODE ---
" Faster way to exit from insert mode
inoremap <localleader><leader> <ESC>

" Jump to the end of the line
inoremap <C-e> <ESC>A


" --- VISUAL MODE ---
" Faster way to exit visual mode
vnoremap <localleader><leader> <ESC>

" Indent mode
vnoremap < <gv
vnoremap > >gv

" Move blocks of text up and down
xnoremap <A-Down> :move '>+1<CR>gv-gv
xnoremap <A-Up> :move '<-2<CR>gv-gv


" --- PLUGINS ---
call plug#begin()

Plug 'tpope/vim-surround'
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'rafi/awesome-vim-colorschemes'
Plug 'ryanoasis/vim-devicons'
Plug 'lervag/vimtex'
" Plug 'tribela/vim-transparent'
Plug 'ayu-theme/ayu-vim' " or other package manager
Plug 'catppuccin/nvim', { 'as': 'catppuccin-mocha' }
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}
Plug 'ARM9/arm-syntax-vim'

call plug#end()

lua require("toggleterm").setup()

" COLORSCHEME
set termguicolors     " enable true colors support
let ayucolor="dark"   " for dark version of theme
colorscheme catppuccin-mocha

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''

let g:airline_theme='catppuccin'
" --- PLUGIN SETTINGS & KEYBINDINGS ---

" NERDtree
nnoremap <leader>e :NERDTreeToggle<CR>

" Telescope find files mode
nnoremap <leader>f :Telescope find_files<CR>

" VimTex settings
let g:vimtex_view_method = 'zathura'
let g:vimtex_view_general_viewer = 'zathura'
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'

" Coc
inoremap <expr> <Tab> pumvisible() ? coc#_select_confirm() : "<Tab>"

" ToggleTerm
nnoremap <leader>t :ToggleTerm<CR>

" ARM syntax
au BufNewFile,BufRead *.s,*.S set filetype=arm " arm = armv6/7
