execute 'source '. expand('<sfile>:h'). '/socket.vim'
execute 'source '. expand('<sfile>:h'). '/renderer.vim'
command! -nargs=+ SocketExec :call socket#command($SERVERNAME, <f-args>)
SocketExec 'call setenv("CLIENTWINDOWID", %d)', $WINDOWID
SocketExec 'command! -nargs=+ SocketExec :call socket#command("%s", <f-args>)', 
      \ v:servername

function! Edit(file) abort
  if expand('%:p') == a:file
    return
  endif
  let bufnr = bufnr(a:file)
  if !bufexists(bufnr)
    silent! execute 'edit '. a:file
    call timer_start(500, {->execute('bufdo set buftype=help')}, {'repeat': 1})
  else
    silent! execute bufnr.'buffer'
  endif
endfunction

function! UpateBuffer(lines)
  let new_lines = a:lines
  let new_length = len(new_lines)
  for idx in range(new_length)
    if idx+1 <= line('$') && getline(idx+1) != new_lines[idx]
      if idx+2 <= line('$') && getline(idx+2) == new_lines[idx]
        silent! call deletebufline(bufnr(), idx+1)
      elseif idx+1 < new_length && getline(idx+1) == new_lines[idx+1]
        let save_cursor = getcurpos()
        silent! call append(idx, new_lines[idx])
        call setpos('.', save_cursor)
      else
        silent! call setline(idx+1, new_lines[idx])
      endif
    elseif idx+1 > line('$')
      silent! call append('$', new_lines[idx])
    endif
  endfor
  if idx+1 < line('$')
    silent! call deletebufline(bufnr(), idx+2, line('$'))
  endif
endfunction


cd /tmp
set nowrap
set statusline=
set cursorline
set laststatus=0
set signcolumn=no
set cmdheight=1
set hidden
set noautoread
set shortmess+=c
set noshowcmd

call renderer#init() "区间标记

SocketExec 'call preview#active(v:true)'
autocmd VimLeavePre * SocketExec 'call preview#close(v:true)'

execute 'source '. stdpath('config'). '/view.vim'
