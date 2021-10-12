let s:commands = {'buffers':[], 'timer_id': -1, 'socket_id': 0}

function! s:commands.empty()
  return empty(self.buffers)
endfunction

function! s:commands.get() dict
  let result = self.buffers[0]
  call remove(self.buffers, 0)
  return result
endfunction

function! s:commands.set(command) dict
  call add(self.buffers, a:command)
  if self.timer_id == -1
    let self.timer_id = s:timer_always(10)
  endif
endfunction

function! s:callback(timer)
  if !s:commands.empty()
    execute s:commands.get()
    let s:callback_idx = 0
  endif
  let s:callback_idx = get(s:, 'callback_idx', 0) + 1
  if s:callback_idx >= 500
    let s:callback_idx = 0
    call s:timer_stop(s:commands.timer_id)
    let s:commands.timer_id = -1
  endif
endfunction

function! s:timer_always(time)
  return timer_start(a:time, function('s:callback'), {'repeat': -1})
endfunction

function! s:timer_stop(timer_id)
  call timer_stop(a:timer_id)
endfunction

function! socket#_command(command_list)
  call s:commands.set(function('printf', a:command_list)())
endfunction

function! socket#command(path, ...)
  if s:commands.socket_id == 0
    let s:commands.socket_id = sockconnect('pipe', a:path, {'rpc': 1})
    if s:commands.socket_id == 0
      return
    else
      autocmd VimLeavePre * call socket#close()
    endif
  endif
  call rpcrequest(s:commands.socket_id, 'nvim_command',
        \ printf('call socket#_command(%s)', a:000))
endfunction

function! socket#close()
  call chanclose(s:commands.socket_id)
  let s:commands.socket_id = 0
endfunction

function! socket#init(path)
  call socket#close()
  let execute_command = 
        \ 'command! -nargs=+ SocketExec :call socket#command("%s", <args>)'
  execute printf(execute_command, a:path)
endfunction
