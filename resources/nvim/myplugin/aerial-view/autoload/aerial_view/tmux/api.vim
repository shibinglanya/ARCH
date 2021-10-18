""" '加载 tmux/api.vim 文件'

function! aerial_view#tmux#api#is_used()
  return aerial_view#tmux#api#get_pane() != v:null
endfunction

function! aerial_view#tmux#api#get_pane()
  return getenv('TMUX_PANE')
endfunction

function! s:get_tmux_output(fval)
  let command = printf('tmux display -p -F "%s" -t "%s"'
        \ , a:fval, aerial_view#tmux#api#get_pane())
  return trim(system(command))
endfunction

function! aerial_view#tmux#api#get_pane_by_tmux()
  return trim(system('tmux display -p -F "#{pane_id}"'))
endfunction

function! s:get_tmux_output_by_tmux(fval)
  let command = printf('tmux display -p -F "%s" -t "%s"'
        \ , a:fval, aerial_view#tmux#api#get_pane_by_tmux())
  return trim(system(command))
endfunction

function! aerial_view#tmux#api#get_session_id()
  return s:get_tmux_output('#{session_id}')
endfunction

function! aerial_view#tmux#api#is_window_focused()
  return s:get_tmux_output('#{window_active},#{pane_in_mode}') == '1,0'
endfunction

function! aerial_view#tmux#api#is_attached()
  let fval = '#{e|>=:#{session_attached},1},#{window_active},#{pane_in_mode}'
  return s:get_tmux_output(fval) == '1,1,0'
endfunction

function! aerial_view#tmux#api#is_attached_by_tmux()
  let fval = '#{e|>=:#{session_attached},1},#{window_active},#{pane_in_mode}'
  return s:get_tmux_output_by_tmux(fval) == '1,1,0'
endfunction

function! aerial_view#tmux#api#is_active()
  let fval = '#{pane_active}'
  return s:get_tmux_output(fval) == '1'
endfunction

function! aerial_view#tmux#api#get_panes()
  let result= []
  for info in split(system('tmux list-panes'), "\n")
    let result = result + [split(info)[6]]
  endfor
  return result
endfunction

function! aerial_view#tmux#api#get_offset()
  let fval = '#{pane_top},#{pane_left},#{pane_bottom}'.
        \ ',#{pane_right},#{window_height},#{window_width}'
  let [top, left, bottom, right, height, width] 
        \ = eval('['.s:get_tmux_output(fval).']')
  return [left, top, height-bottom, width-right]
endfunction

function! aerial_view#tmux#api#get_client_pid()
  return s:get_tmux_output_by_tmux('#{client_pid}')
endfunction

function! aerial_view#tmux#api#set_env(name, value)
  call system(printf('tmux set-environment -t "%s" %s %s'
        \ , aerial_view#tmux#api#get_session_id(), a:name, string(a:value)))
endfunction

function! aerial_view#tmux#api#get_env(name)
  let ret = system(printf('tmux show-environment -t "%s" %s'
        \ , aerial_view#tmux#api#get_session_id(), a:name))
  return ret =~ 'unknown variable:' ? v:null : split(trim(ret), '\V=')[1]
endfunction

let s:tmux_runtime_path = expand('<sfile>:h'). '/api_runtime.vim'

function! s:register_hook(flag, event, func)
  let nvim_command = printf("call setenv('SERVERINFO', '%s,%s')|source %s|quit",
      \ v:servername, substitute(string(a:func), '\V''', '''''', 'g'), 
      \ s:tmux_runtime_path)
  call system(printf(
  \ 'tmux set-hook -%s %s "run-shell \"nvim --headless --cmd \\\"%s\\\"\""',
        \ a:flag, printf("%s[%d]", a:event, getpid()), nvim_command))
endfunction

function! s:unregister_hook(flag, event)
  call system(printf('tmux set-hook -%su %s', 
        \ a:flag, printf("%s[%d]", a:event, getpid())))
endfunction

function! aerial_view#tmux#api#register_hook(event, func)
  call s:register_hook('p', a:event, a:func)
endfunction

function! aerial_view#tmux#api#unregister_hook(event)
  call s:unregister_hook('p', a:event)
endfunction

function! aerial_view#tmux#api#register_window_hook(event, func)
  call s:register_hook('w', a:event, a:func)
endfunction

function! aerial_view#tmux#api#unregister_window_hook(event)
  call s:unregister_hook('w', a:event)
endfunction

function! aerial_view#tmux#api#register_global_hook(event, func)
  call s:register_hook('g', a:event, a:func)
endfunction

function! aerial_view#tmux#api#unregister_global_hook(event)
  call s:unregister_hook('g', a:event)
endfunction
