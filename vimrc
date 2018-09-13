"        _
" __   _(_)_ __ ___  _ __ ___
" \ \ / / | '_ ` _ \| '__/ __|
"  \ V /| | | | | | | | | (__
"   \_/ |_|_| |_| |_|_|  \___|

" Turn off vi compatibility
set nocompatible

" execute pathogen#infect()

" Vundle
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Vundle
Plugin 'VundleVim/Vundle.vim'
Plugin 'skalnik/vim-vroom' " Vroom (Rspec)
Plugin 'kien/ctrlp.vim' " Ctrl P (Fuzzy Finder)
Plugin 'tpope/vim-rails.git' " Vim Rails
Plugin 'vim-ruby/vim-ruby' " Vim Ruby
Plugin 'tComment' " TComment
Plugin 'mattn/emmet-vim' " Vim Emmet
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'flazz/vim-colorschemes'

" Theme GruvBox

" Trigger configuration. Do not use <tab> if you use
" https://github.com/Valloric/YouCompleteMe.
" let g:UltiSnipsExpandTrigger="<tab>"
" let g:UltiSnipsJumpForwardTrigger="<c-b>"
" let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
" let g:UltiSnipsEditSplit="vertical"

call vundle#end()
filetype plugin indent on

" Basic visual settings
set t_Co=256
syntax on
set background=dark
set colorcolumn=100
set number
set tabstop=2
set shiftwidth=2
set smartindent
set autoindent
set expandtab
set relativenumber

" Show file options above the command line
set wildmenu

" We can use different key mappings for easy navigation between splits to save a keystroke.
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
" highlight ColorColumn  ctermbg=237
" highlight LineNr       ctermbg=236 ctermfg=240
" highlight StatusLineNC ctermbg=238 ctermfg=0
" highlight StatusLine   ctermbg=240 ctermfg=232
" highlight Visual       ctermbg=240   ctermfg=0
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

" training macro to get rid of arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

syntax enable
" colorscheme solarized
