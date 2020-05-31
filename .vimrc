set autoindent
set expandtab
set tabstop=4
set shiftwidth=4

set hlsearch
set incsearch

set backspace=indent,eol,start
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc,.png,.jpg
set wildignore=*.swp,*.bak

set number
syntax on

" Redraw the screen and unhighlight search matches
nnoremap <silent> <C-l> :nohl<CR><C-l>

" Restore cursor position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif
