" Vim config: plain editing settings + clangd for C/C++ (completion,
" go-to-definition, diagnostics, format on save) via the yegappan/lsp plugin
" in ~/.vim/pack/plugins/start/lsp. Needs Vim 9+ and `clangd` on PATH.
" Per-project clangd settings belong in that project's .clangd file.

" ---------------------------------------------------------------------------
" Basics

set nocompatible
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab autoindent
let &t_SI = "\e[6 q"   " insert mode: thin bar
let &t_SR = "\e[4 q"   " replace mode: underline
let &t_EI = "\e[2 q"   " normal mode: block
set ttimeoutlen=10

syntax on
filetype plugin indent on
set number
set showmatch
set hlsearch incsearch
set ignorecase smartcase
set background=dark
" Built-in theme; others to try with :colorscheme <name>:
" retrobox, sorbet, wildcharm, zaibatsu, slate, desert
silent! colorscheme habamax
set mouse=a
set ruler
if has('clipboard')
  set clipboard=unnamed     " yank/paste use the system clipboard
endif

" ---------------------------------------------------------------------------
" Editing comfort

set hidden                 " jump to another file without saving first
set signcolumn=yes         " keep the diagnostics gutter from shifting text
set updatetime=300
set completeopt=menuone,noinsert,noselect,popup
set shortmess+=c
set wildmenu
set backspace=indent,eol,start
set path+=**               " :find <name> searches the whole repo

let mapleader = ' '

" Clear search highlight
nnoremap <silent> <Esc><Esc> :nohlsearch<CR>

" Tab / Shift-Tab walk the completion menu.
" Enter accepts the highlighted item; with nothing highlighted it is a
" normal newline.
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR>    pumvisible() && complete_info(['selected']).selected != -1 ? "\<C-y>" : "\<CR>"

" ---------------------------------------------------------------------------
" Plugins: native packages under ~/.vim/pack

" Indentation etc. from the project's .editorconfig, when it has one
packadd! editorconfig

" ---------------------------------------------------------------------------
" clangd (via yegappan/lsp)

function! s:LspSetup() abort
  call LspOptionsSet(#{
        \ autoComplete: v:true,
        \ autoHighlightDiags: v:true,
        \ showDiagWithVirtualText: v:true,
        \ diagVirtualTextAlign: 'after',
        \ diagVirtualTextWrap: 'truncate',
        \ showDiagOnStatusLine: v:false,
        \ showSignature: v:true,
        \ snippetSupport: v:false,
        \ noNewlineInCompletion: v:true,
        \ ignoreMissingServer: v:true,
        \ })
  call LspAddServer([#{
        \ name: 'clangd',
        \ filetype: ['c', 'cpp'],
        \ path: 'clangd',
        \ args: [
        \   '--background-index',
        \   '--header-insertion=never',
        \ ],
        \ }])
endfunction

function! s:LspAttached() abort
  nnoremap <buffer> <silent> gd         :LspGotoDefinition<CR>
  nnoremap <buffer> <silent> gD         :LspGotoDeclaration<CR>
  nnoremap <buffer> <silent> gi         :LspGotoImpl<CR>
  nnoremap <buffer> <silent> gr         :LspShowReferences<CR>
  nnoremap <buffer> <silent> K          :LspHover<CR>
  nnoremap <buffer> <silent> <leader>rn :LspRename<CR>
  nnoremap <buffer> <silent> <leader>a  :LspCodeAction<CR>
  nnoremap <buffer> <silent> <leader>h  :LspSwitchSourceHeader<CR>
  nnoremap <buffer> <silent> <leader>o  :LspDocumentSymbol<CR>
  nnoremap <buffer> <silent> <leader>s  :LspSymbolSearch<CR>
  nnoremap <buffer> <silent> <leader>d  :LspDiag current<CR>
  nnoremap <buffer> <silent> <leader>D  :LspDiag show<CR>
  nnoremap <buffer> <silent> ]d         :LspDiag next<CR>
  nnoremap <buffer> <silent> [d         :LspDiag prev<CR>
  nnoremap <buffer> <silent> <leader>f  :LspFormat<CR>
  xnoremap <buffer> <silent> <leader>f  :LspFormat<CR>
  let b:lsp_attached = 1
endfunction

" Format on save through clangd (uses the project's .clang-format).
" Turn off for a session with  :let g:format_on_save = 0
let g:format_on_save = 1

function! s:FormatOnSave() abort
  if get(g:, 'format_on_save', 0) && get(b:, 'lsp_attached', 0)
    let l:view = winsaveview()
    silent! LspFormat
    call winrestview(l:view)
  endif
endfunction

augroup vimrc_lsp
  autocmd!
  autocmd User LspSetup    call s:LspSetup()
  autocmd User LspAttached call s:LspAttached()
  autocmd BufWritePre *.hpp,*.cpp,*.h,*.cc,*.c call s:FormatOnSave()
augroup END

" ---------------------------------------------------------------------------
" Terminal (uses $SHELL)

" Space tt: terminal in a split below, starting in the current file's folder
nnoremap <silent> <leader>tt :botright call term_start(&shell, #{cwd: isdirectory(expand('%:p:h')) ? expand('%:p:h') : getcwd(), term_rows: 15, term_finish: 'close'})<CR>
" Esc Esc leaves terminal insert mode so you can scroll / yank the output
tnoremap <Esc><Esc> <C-\><C-n>

" ---------------------------------------------------------------------------
" No syntax highlighting for C++ files inside ~/leetcode
autocmd FileType cpp if expand('%:p') =~# '^' . expand('~/leetcode/') | setlocal syntax=off | endif
