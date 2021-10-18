""" '加载 tmux/events.vim 文件'

function! aerial_view#tmux#events#init()
""" '初始化: tmux_events'
  let s:pane = aerial_view#tmux#api#get_pane()

  call aerial_view#tmux#api#register_hook('pane-focus-in', 
        \ function('s:pane_focus_in'))

  call aerial_view#tmux#api#register_hook('session-window-changed', 
        \ function('s:session_window_changed'))

  call aerial_view#tmux#api#register_window_hook('pane-mode-changed', 
        \ function('s:pane_mode_changed'))

  call aerial_view#tmux#api#register_hook('client-attached', 
        \ function('s:client_attached'))
  call aerial_view#tmux#api#register_hook('client-detached', 
        \ function('s:client_detached'))

  call aerial_view#tmux#api#register_window_hook('client-session-changed', 
        \ function('s:client_session_changed'))
endfunction

function! aerial_view#tmux#events#destroy()
  call aerial_view#tmux#api#unregister_hook('pane-focus-in')
  call aerial_view#tmux#api#unregister_hook('session-window-changed')
  call aerial_view#tmux#api#unregister_window_hook('pane-mode-changed')
  call aerial_view#tmux#api#unregister_hook('client-attached')
  call aerial_view#tmux#api#unregister_hook('client-detached')
  call aerial_view#tmux#api#unregister_window_hook('client-session-changed')
endfunction

function! s:pane_focus_in()
  "if aerial_view#tmux#api#is_attached()
""" 'TMUX事件: {PANE: %s} {pane_focus_in 触发: 进入}', s:pane
    doautocmd User AerialViewTMUXFocusEnter
  "endif
endfunction

function! s:session_window_changed()
  if aerial_view#tmux#api#is_attached()
""" 'TMUX事件: {PANE: %s} {session_window_changed 触发: 进入}', s:pane
    doautocmd User AerialViewTMUXEnter
  else
""" 'TMUX事件: {PANE: %s} {session_window_changed 触发: 离开}', s:pane
    doautocmd User AerialViewTMUXLeave
  endif
endfunction

function! s:pane_mode_changed()
  if aerial_view#tmux#api#is_attached_by_tmux()
""" 'TMUX事件: {PANE: %s} {pane_mode_changed 触发: 进入}', s:pane
    doautocmd User AerialViewTMUXEnter
  else
""" 'TMUX事件: {PANE: %s} {pane_mode_changed 触发: 离开}', s:pane
    doautocmd User AerialViewTMUXLeave
  endif
endfunction

function! s:client_attached()
  if aerial_view#tmux#api#is_attached()
""" 'TMUX事件: {PANE: %s} {client_attached 触发: 重新进入显示}', s:pane
    doautocmd User AerialViewTMUXClientEnter_Show
  else
""" 'TMUX事件: {PANE: %s} {client_attached 触发: 重新进入隐藏}', s:pane
    doautocmd User AerialViewTMUXClientEnter_Hide
  endif
endfunction

function! s:client_detached()
""" 'TMUX事件: {PANE: %s} {client_detached 触发: 离开}', s:pane
  doautocmd User AerialViewTMUXClientLeave
endfunction

function! s:client_session_changed()
  if aerial_view#tmux#api#is_attached()
""" 'TMUX事件: {PANE: %s} {client_session_changed 触发: 进入}', s:pane
    doautocmd User AerialViewTMUXEnter
  else
""" 'TMUX事件: {PANE: %s} {client_session_changed 触发: 离开}', s:pane
    doautocmd User AerialViewTMUXLeave
  endif
endfunction
