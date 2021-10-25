execute 'source '. expand('<sfile>:h'). '/scroll_bar.vim'

execute 'source '. expand('<sfile>:h'). '/socket.vim'
call aerial_view#socket#init($SERVERNAME)
SocketExec 'call aerial_view#socket#init("%s")', v:servername

SocketExec 'call setenv("CLIENTWINDOWID", %d)', $WINDOWID

function! Cursor(beg, end, set_pos)
  call setpos('.', a:set_pos)
  normal zz
  call scroll_bar#flush(a:beg, a:end)
endfunction

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

function! s:timer_always(time, callback)
  return timer_start(a:time, a:callback, {'repeat': -1})
endfunction

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

autocmd VimLeavePre * SocketExec 'call aerial_view#preview#close("preview_runtime")'

execute 'source '. stdpath('config'). '/view.vim'

SocketExec 'call aerial_view#preview#active(v:true)'
