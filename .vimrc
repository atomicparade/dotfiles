set autoindent
set expandtab
set tabstop=4
set shiftwidth=4
" Map Shift-tab to unindent
inoremap <S-Tab> <C-d>

set hlsearch
set incsearch
set number

set backspace=indent,eol,start
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc,.png,.jpg
set wildignore=*.swp,*.bak

syntax on

autocmd BufRead,BufNewFile */nginx/sites-available/* set ft=nginx
autocmd BufRead,BufNewFile */apparmor.d/* set ft=apparmor

" Map C-l to redraw the screen and unhighlight search matches
nnoremap <silent> <C-l> :nohl<CR><C-l>

" Restore cursor position when reopening a file
if has("autocmd")
    au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif
