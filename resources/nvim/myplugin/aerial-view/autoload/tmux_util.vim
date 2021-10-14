function! tmux_util#is_used()
  return !empty($TMUX) && tmux_util#get_pane() != v:null
endfunction

function! tmux_util#get_pane()
  return getenv('TMUX_PANE')
endfunction

function! s:get_tmux_output(fval)
  let command = printf('tmux display -p -F "%s" -t "%s"'
        \ , a:fval, tmux_util#get_pane())
  return trim(system(command))
endfunction

function! tmux_util#get_session_id()
  return s:get_tmux_output('#{session_id}')
endfunction

function! tmux_util#is_window_focused()
  return s:get_tmux_output('#{window_active},#{pane_in_mode}') == '1,0'
endfunction

function! tmux_util#get_offset()
  let fval = '#{pane_top},#{pane_left},#{pane_bottom}'.
        \ ',#{pane_right},#{window_height},#{window_width}'
  let [top, left, bottom, right, height, width] 
        \ = eval('['.s:get_tmux_output(fval).']')
  return [left, top, height-bottom, width-right]
endfunction

function! tmux_util#set_env(name, value)
  call system(printf('tmux set-environment -t "%s" %s %s'
        \ , tmux_util#get_session_id(), a:name, string(a:value)))
endfunction

function! tmux_util#get_env(name)
  let ret = system(printf('tmux show-environment -t "%s" %s'
        \ , tmux_util#get_session_id(), a:name))
  return ret =~ 'unknown variable:' ? v:null : split(trim(ret), '\V=')[1]
endfunction

let s:tmux_runtime_path = expand('<sfile>:h'). '/tmux_runtime.vim'

function! tmux_util#register_hook(event, func)
  let nvim_command = printf("call setenv('SERVERINFO', '%s,%s')|source %s|quit",
      \ v:servername, substitute(string(a:func), '\V''', '''''', 'g'), 
      \ s:tmux_runtime_path)
  call system(printf(
  \ 'tmux set-hook -t "%s" %s "run-shell \"nvim --headless --cmd \\\"%s\\\"\""',
        \ tmux_util#get_pane(), a:event, nvim_command))
endfunction

function! tmux_util#unregister_hook(event)
  call system(printf('tmux set-hook -u -t "%s" %s', 
        \ tmux_util#get_pane(), a:event))
endfunction
