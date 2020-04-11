"        _
" __   _(_)_ __ ___  _ __ ___
" \ \ / / | '_ ` _ \| '__/ __|
"  \ V /| | | | | | | | | (__
"   \_/ |_|_| |_| |_|_|  \___|

" ===========
" Plugins
" ===========
"
call plug#begin('~/.vim/plugged')

" Collection of color schemes
Plug 'rafi/awesome-vim-colorschemes'

" More text objects
Plug 'wellle/targets.vim'

" Quick look at vim buffers/registers
Plug 'junegunn/vim-peekaboo'

" Use fzf for fuzzy search
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Use nerdtree for a file explorer 
Plug 'preservim/nerdtree'

call plug#end()

" ===========
" Configs
" ===========
"
" Use the colorscheme
colorscheme OceanicNext

" Turn off vi compatibility
set nocompatible

" Add FZF to runtimepath
set rtp+=/usr/local/opt/fzf

" Trigger configuration. Do not use <tab> if you use
" https://github.com/Valloric/YouCompleteMe.
" let g:UltiSnipsExpandTrigger="<tab>"
" let g:UltiSnipsJumpForwardTrigger="<c-b>"
" let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
" let g:UltiSnipsEditSplit="vertical"

" Basic visual settings
set t_Co=256
syntax on
set background=dark
set colorcolumn=140
set number
set tabstop=2
set shiftwidth=2
set smartindent
set autoindent
set expandtab
set relativenumber

" Show file options above the command line
set wildmenu

" Use different key mappings for easy navigation between splits to save a keystroke.
" So instead of ctrl-w then j, it’s just ctrl-j:
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Open new split panes to right and bottom, which feels more natural than Vim’s default:
set splitbelow
set splitright

set hlsearch

" Handle ugly whitespace
set list listchars=tab:>-,trail:•,precedes:<,extends:>

" Big remaps
" let mapleader = ','
" :imap jj <ESC>

" load indent file for the current filetype
" filetype indent on

" Bars
" highlight clear SignColumn
" highlight VertSplit    ctermbg=236
highlight ColorColumn  ctermbg=237
highlight LineNr       ctermbg=236
" highlight StatusLineNC ctermbg=238 ctermfg=0
" highlight StatusLine   ctermbg=240 ctermfg=232
" highlight Visual       ctermbg=240 ctermfg=0
" highlight Pmenu        ctermbg=240 ctermfg=12
" highlight PmenuSel     ctermbg=3   ctermfg=1
" highlight SpellBad     ctermbg=0   ctermfg=1

" highlight Cursor guifg=white guibg=black
" highlight iCursor guifg=white guibg=steelblue
" set guicursor=n-v-c:block-Cursor
" set guicursor+=i:ver100-iCursor
" set guicursor+=n-v-c:blinkon0
" set guicursor+=i:blinkwait10

" first, enable status line always
" set laststatus=2
" if version >= 700
"   au InsertEnter * hi StatusLine ctermfg=226 ctermbg=232
"   au InsertLeave * hi StatusLine ctermbg=240 ctermfg=232
" endif

" Make those debugger statements painfully obvious
" au BufEnter *.rb syn match error contained "\<binding.pry\>"
" au BufEnter *.rb syn match error contained "\<debugger\>"

 " ridiculous macro for formatting Ruby hashes
" :nnoremap <leader>fh $v%lohc<CR><CR><Up><C-r>"<Esc>:s/,/,\r/g<CR>:'[,']norm ==<CR>

" Disable navigation with arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

if has('nvim')
  " Use escape key to exit terminal mode
  tnoremap <Esc> <C-\><C-n>

  " Use Alt-[ to as Esc key for terminal mode
  tnoremap <A-[> <Esc>
endif
syntax enable
