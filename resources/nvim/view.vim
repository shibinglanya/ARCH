"添加配对的字符
set mps+=<:>
"NVIM内部使用的字符编码方式
set encoding=utf-8
"文件保存编码
set fileencoding=utf-8
"TAB宽度
set shiftwidth=2
"设置制表符为4的倍数"
set softtabstop=2
"文件里的 <Tab> 代表的空格数
set tabstop=2
"插入模式里: 插入 <Tab> 时使用合适数量的空格
set expandtab

let g:plug_url_format = "https://git::@ghproxy.com/https://github.com/%s.git"

call plug#begin('~/.config/nvim/plugged')
Plug '~/.config/nvim/myplugin/vim-hybrid'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug '~/.config/nvim/myplugin/lsp_cxx_highlight', { 'for': [ 'c', 'cpp' ] }
Plug 'luochen1990/rainbow'
call plug#end()


function! s:create_win(win_x, win_y, width, height, bufnr, priority)
  let opts = {'relative': 'win', 'width': a:width, 'height': a:height,
      \ 'row': a:win_y, 'col': a:win_x, 'zindex': a:priority,
      \ 'anchor': 'NW', 'style': 'minimal', 'noautocmd': 1, 'focusable': 0}
  let wid = nvim_open_win(a:bufnr, 0, opts)
  call nvim_win_set_option(wid, 'winhl', 'Normal:MyHighlight')
  return wid
endfunction

function! s:create_buf()
  let bufnr = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(bufnr, 0, -1, v:true, [])
  return bufnr
endfunction


"function! s:init()
"  call s:create_win(5, 5, 5, 20, s:create_buf(), 1)
"endfunction
"autocmd VIMENTER * call s:init()



colorscheme hybrid
set updatetime=500

let g:rainbow_active = 1
let ctermfgs = [2, 165, 1, 214]
let parentheses = [
      \ 'start=/\v(( |\<)@<!\<|\<( |\<)@!)((\s|\S|\n){-}( )@<!\>( )@!)@=/ end=/>/ fold',
      \ 'start=/(/ end=/)/ fold', 
      \ 'start=/\[/ end=/\]/ fold', 
      \ 'start=/{/ end=/}/ fold'
      \]
let g:rainbow_conf = {
      \ 'cterms': ['bold'],
      \ 'ctermfgs': ctermfgs,
      \ 'operators': '_,_',
      \ 'parentheses': parentheses
      \}

autocmd VimEnter * hi ViewHighlight cterm=bold ctermfg = 190
