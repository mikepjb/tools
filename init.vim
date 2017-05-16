" vimrc
" Author:       Michael Bruce <http://michaelbruce.online/>
"
" This is your survival vim setup
" vim:set ts=2 sts=2 sw=2 expandtab:

autocmd!

silent! call plug#begin('~/.config/nvim/plugged')

Plug 'michaelbruce/vim-sane'
Plug 'michaelbruce/vim-alternator', { 'on' : ['Alternate', 'Test'] }
Plug 'michaelbruce/vim-notes',   { 'for' : 'notes' }
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'junegunn/rainbow_parentheses.vim', { 'on' : 'RainbowParentheses' }
Plug 'guns/xterm-color-table.vim', { 'on' : 'XtermColorTable' }

" Languages
Plug 'sentient-lang/vim-sentient', { 'for' : 'sentient' }
Plug 'michaelbruce/vim-chruby', { 'for' : 'ruby' }
Plug 'michaelbruce/ice.nvim'
Plug 'michaelbruce/vim-parengage', { 'for' : ['clojure', 'lisp'] }
Plug 'guns/vim-clojure-static', { 'for' : 'clojure' }
Plug 'guns/vim-clojure-highlight', { 'for' : 'clojure' }
Plug 'rust-lang/rust.vim',  { 'for': 'rust' }
Plug 'cespare/vim-toml',  { 'for': 'toml' }
Plug 'junegunn/vader.vim',  { 'on': 'Vader', 'for': 'vader' }

call plug#end()

syn on

augroup filetypeCustomisations
  autocmd!
  au FileType python setl sw=2 sts=2 et
  au FileType vim setl sw=2 sts=2 et
  au FileType r setl sw=2 sts=2 et
  au FileType gitcommit set textwidth=72
  autocmd FileType c set complete-=i
  autocmd BufNewFile,BufReadPost *.notes set filetype=notes
  autocmd BufNewFile,BufReadPost *.cls set filetype=java
  autocmd BufNewFile,BufReadPost *.trigger set filetype=java
  autocmd BufNewFile,BufReadPost *.component set filetype=htmlm4
  autocmd BufNewFile,BufReadPost *.page set filetype=htmlm4
  autocmd BufNewFile,BufReadPost *.html set filetype=htmlm4
  autocmd BufNewFile,BufReadPost *.md set filetype=markdown
  autocmd BufNewFile,BufReadPost *.boot set filetype=clojure
  autocmd BufNewFile,BufReadPost *.pxi set filetype=clojure
  autocmd BufNewFile,BufReadPost .Rprofile set filetype=r
augroup END

set background=light
color night

if has("gui_running")
    set guifont=Inconsolata:h16
    set guioptions-=r
    set lines=50 columns=120
endif

" Disables BCE, Background color erase - allows non-text background to be
" filled under tmux
set t_ut=

set cursorline
set iskeyword+=- " Autocomplete words that include hyphen
set re=1 " vim-ruby still runs slowly on the newer regex engine...
set ttyfast

let mapleader= ' '
map gy :Alternate<CR>
nnoremap <CR> :Test<CR>
map <Leader>e :e <C-R>=expand('%:p:h')<CR>/

" Treat - as a word seperator when using C-w e.g (defn stream-file)
set iskeyword-=-

" TODO duplicate from alternator - fireplace needs autocmd to allow cqq CR
" ------------------------------------------------------------------------
function! MapCR()
  nnoremap <cr> :Test<cr>
endfunction
call MapCR()

" Leave the return key alone when in command line windows, since it's used
" to run commands there.
autocmd! CmdwinEnter * silent! unmap <cr>
autocmd! CmdwinLeave * silent! call MapCR()
" ------------------------------------------------------------------------

inoremap <C-d>        <C-o>x
inoremap <C-f>        <C-o>l
inoremap <C-b>        <C-o>h

function! Tags()
    exec "!ctags -R $(git rev-parse --show-toplevel || echo \".\")"
endfunction

command! Tags :call Tags()

let g:clojure_syntax_keywords = {
    \ 'clojureMacro': ["deftask", "defproject", "defcustom"],
    \ 'clojureFunc': ["string/join", "string/replace"]
    \ }

if has('nvim')
    map <M-o> <C-\><C-n><C-w><C-w>
    tmap <M-o> <C-\><C-n><C-w><C-w>
endif

function! Scratch()
    normal 
    enew
    set ft=clojure
endfunction

command! Scratch :call Scratch()

" use lisp ft for scheme shell scripts
if did_filetype()
    finish
endif
if getline(1) =~# '^#!.*/usr/bin/env\s\+scsh.*\>'
    setfiletype lisp
endif

nnoremap <leader>y :belowright split \| term tmux attach -t repl<CR>

function! SyntaxStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

command! SyntaxStack :call SyntaxStack()

function! Selecta() abort
  belowright split
  enew
  let options = { 'buf': bufnr('') }

  function! options.on_stdout(job_id, data, event)
    let g:selecta_output = substitute(join(a:data), "", "", "g")
  endfunction

  function! options.on_exit(id, code, _event)
    execute 'bd!' self.buf
    execute 'e ' . g:selecta_output
  endfunction

  call termopen("echo -ne $(find ./* -path ./target -prune -o -type f -print | selecta)", options)
  startinsert
endfunction

command! Selecta call Selecta()

nnoremap <leader>f :Selecta<CR>

" set vim-r-plugin to
let r_indent_align_args = 0

" Set vim-r-plugin to mimics ess :
let r_indent_ess_comments = 0
let r_indent_ess_compatible = 0
