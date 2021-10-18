""" '加载 preview.vim 文件'

let s:preview = {
  \ 'active':           v:false,
  \ 'is_hidden':        v:false,
  \ 'main_path':        expand('<sfile>:h').'/../../cxx/main',
  \ 'win_runtime_path': expand('<sfile>:h').'/preview_runtime.vim',
  \ 'tmux':             {'is_used': v:false, 'is_registered': v:false},
  \ }


if !empty($TMUX) && aerial_view#tmux#api#is_used()
  let s:preview.tmux.is_used = v:true
  let s:preview.tmux.pane = aerial_view#tmux#api#get_pane()
endif

function! aerial_view#preview#open(who, font, win_columns)
""" '尝试打开视图，由 %s 触发', a:who
  if aerial_view#preview#active()
    return
  endif

  call s:start_task_of_detecting_columns(a:win_columns) "VimResized

  call s:run_main(a:font, a:win_columns)

  function! s:show_task(who, win_columns, timer)
    if aerial_view#preview#active()
      if a:who == 'tmux-hide'
        call s:hide_resize(&columns, 0, a:win_columns, &lines)
      else
        call s:move_resize(&columns, 0, a:win_columns, &lines)
      endif
      call s:switch()
      call s:update_buffer(v:true)
      call s:update_cursor()
      call s:timer_stop(a:timer)

      call s:register_events()

      if s:preview.tmux.is_used && !s:preview.tmux.is_registered
        call s:register_tmux_events()
      endif

""" '打开视图，由 %s 触发', a:who

    endif
  endfunction

  call s:timer_always(200, function('s:show_task', [a:who, a:win_columns]))
endfunction

function! aerial_view#preview#close(who) "在win_runtime.vim中会调用
""" '尝试关闭视图，由 %s 触发', a:who
  if !aerial_view#preview#active()
    return
  endif

  call aerial_view#preview#active(v:false)
  call jobstop(s:preview.job_id)

  call s:unregister_events()
  if a:who == 'self'
    call s:unregister_tmux_events()
  endif

  call s:stop_task_of_detecting_columns()

""" '关闭视图，由 %s 触发', a:who
""" ''
endfunction

function! aerial_view#preview#hide(who)
  if !s:preview.is_hidden
    call s:hide()
  endif
endfunction

function! aerial_view#preview#show(who)
  if s:preview.is_hidden
    call s:show()
  endif
endfunction

function! s:timer_always(time, callback)
  return timer_start(a:time, a:callback, {'repeat': -1})
endfunction

function! s:timer_stop(timer)
  call timer_stop(a:timer)
endfunction

function! s:get_windowid()
  if s:preview.tmux.is_used
    let pid = aerial_view#tmux#api#get_client_pid()
    let result = filter(split(system('cat /proc/'. pid. '/environ')), 
          \ 'v:val =~ "\\v^WINDOWID\\="')
    return split(result[0], '\V=')[1]
  endif
  return $WINDOWID
endfunction

function! s:run_main(font, win_columns)
  let s:preview.font = a:font
  let s:preview.win_columns = a:win_columns
  let s:preview.parent_windowid = s:get_windowid()
  let command = [s:preview.main_path]
  let command = command + ['-font', a:font]
  let command = command + ['-embed', s:preview.parent_windowid]
  let command = command + ['-config', s:preview.win_runtime_path]
  let command = command + ['--finish']
  let s:preview.job_id = 
        \ jobstart(command, {'env':{'SERVERNAME': v:servername}})
endfunction

function! s:register_events()
  augroup AerialView_Preview
    autocmd!
    autocmd CursorMoved,CursorMovedI * call s:update_cursor()
    autocmd CursorHold,CursorHoldI * call s:update_buffer(v:false)
    autocmd BufEnter * call s:switch()
    autocmd TextChanged,TextChangedI * let b:is_modified = v:true
    autocmd VimLeave * call aerial_view#preview#close('self')
  augroup END
endfunction

function! s:unregister_events()
  augroup AerialView_Preview
    autocmd!
  augroup END
endfunction

function! s:tmux_focus_enter()
  if !aerial_view#preview#active()
    call aerial_view#preview#open('aerial_view#preview#show', 
          \ s:preview.font, s:preview.win_columns)
    return
  endif
  let windowid = s:get_windowid()
  if windowid != s:preview.parent_windowid
""" '由 tmux_focus_enter 触发的父窗口调整: {src: %d, dst: %d}', s:preview.parent_windowid, windowid
    let s:preview.parent_windowid = windowid
    call s:reparent(windowid)
  endif
endfunction

function! s:register_tmux_events()
  call aerial_view#tmux#events#init()

  autocmd! User AerialViewTMUXFocusEnter call s:tmux_focus_enter()
  autocmd! User AerialViewTMUXLeave call aerial_view#preview#hide('tmux')
  autocmd! User AerialViewTMUXEnter call aerial_view#preview#show('tmux')
  autocmd! User AerialViewTMUXClientLeave call aerial_view#preview#close('tmux')
  execute printf(
    \ 'autocmd! User AerialViewTMUXClientEnter_Show call aerial_view#preview#open("%s", "%s", %d)'
    \, 'tmux-show', s:preview.font, s:preview.win_columns)
  execute printf(
    \ 'autocmd! User AerialViewTMUXClientEnter_Hide call aerial_view#preview#open("%s", "%s", %d)'
    \, 'tmux-hide', s:preview.font, s:preview.win_columns)

  let s:preview.tmux.is_registered = v:true
endfunction

function! s:unregister_tmux_events()
  if !s:preview.tmux.is_registered
    return
  endif

  autocmd! User AerialViewTMUXFocusEnter
  autocmd! User AerialViewTMUXClientEnter_Show
  autocmd! User AerialViewTMUXClientEnter_Hide
  autocmd! User AerialViewTMUXClientLeave
  autocmd! User AerialViewTMUXEnter
  autocmd! User AerialViewTMUXLeave

  call aerial_view#tmux#events#destroy()

  let s:preview.tmux.is_registered = v:false
endfunction

function! aerial_view#preview#active(...) "在win_runtime.vim中会调用,以更新状态
  if len(a:000) == 1 && type(a:1) == v:t_bool
    let s:preview.active = a:1
  endif
  return s:preview.active
endfunction

function! s:get_current_file_path()
  let result = expand('%:p')
  if empty(result)
    let bufnr = bufnr()
    if !has_key(get(s:, 'bufnr2path_dict', {}), bufnr())
      if !exists('s:bufnr2path_dict')
        let s:bufnr2path_dict = {}
      endif
      let s:bufnr2path_dict[bufnr] = tempname()
    endif
    return s:bufnr2path_dict[bufnr]
  endif
  return result
endfunction

function! s:switch()
  if buflisted(bufnr()) && exists(':SocketExec') && aerial_view#preview#active()
    let file_path = s:get_current_file_path()
    execute printf("SocketExec \"call Edit('%s')\"", file_path)
  endif
endfunction

function! s:update_cursor()
  if buflisted(bufnr()) && exists(':SocketExec') && aerial_view#preview#active()
    SocketExec "call Cursor(%d, %d, %s)", 
          \ line('w0'), line('w$'), getcurpos()
  endif
endfunction

function! s:update_buffer(bool)
  if !a:bool && get(b:, 'is_modified', v:false) == v:false
    return
  endif
  let b:is_modified = v:false
  if buflisted(bufnr()) && exists(':SocketExec') && aerial_view#preview#active()
    SocketExec "call UpateBuffer(%s)", string(getline(1, '$'))
  endif
endfunction

function! aerial_view#preview#get_info()
  return s:preview
endfunction

function! s:task_of_detecting_columns(win_columns, timer)
  let s:detected_columns = get(s:, 'detected_columns', &columns)
  if s:detected_columns != &columns
    "有足够的位置显示窗口
    if &columns - &colorcolumn > a:win_columns
      let s:detected_columns = &columns - a:win_columns
      let s:old_columns = &columns
      if !s:preview.is_hidden 
        execute printf("set columns=%d", s:detected_columns)
""" '由 task_of_detecting_columns 触发的调整窗口SIZE: {old_columns: %d, &columns: %d}', s:old_columns, &columns
        call s:move_resize(s:detected_columns, 0, a:win_columns, &lines)
      endif
    else
      call s:hide()
      let s:preview.is_hidden = v:false
      let s:detected_columns = &columns
    endif
  endif
endfunction

function! s:start_task_of_detecting_columns(win_columns)
  if &columns - &colorcolumn > a:win_columns
    let s:old_columns = &columns
    let &columns = &columns - a:win_columns
    let s:detected_columns = &columns
""" '由 start_task_of_detecting_columns 触发的调整窗口: {old_columns: %d, &columns: %d}', s:old_columns, &columns
  endif
  let s:timer_id_of_detecting_columns = s:timer_always(200, 
        \ function('s:task_of_detecting_columns', [a:win_columns]))
endfunction

function! s:stop_task_of_detecting_columns()
  call timer_stop(get(s:, 'timer_id_of_detecting_columns', -1))
  "恢复&columns
  let s:old_columns = get(s:, 'old_columns', &columns)
  if s:old_columns != &columns
    execute printf("set columns=%d", s:old_columns)
""" '由 stop_task_of_detecting_columns 触发的调整窗口: {old_columns: %d, &columns: %d}', s:old_columns, &columns
  endif
endfunction

function! s:chansend(...)
  call chansend(s:preview.job_id, 
        \ function('printf', a:000 + [$CLIENTWINDOWID])())
endfunction

function! s:move(col_x, row_y)
  if aerial_view#preview#active()
    if s:preview.tmux.is_used
      let [offset_x, offset_y, _, _] = aerial_view#tmux#api#get_offset()
    else
      let [offset_x, offset_y] = [0, 0]
    endif
    call s:chansend("move\n%d %d %d\n", offset_x + a:col_x, offset_y + a:row_y)
  endif
endfunction

function! s:hide()
  if aerial_view#preview#active() && !s:preview.is_hidden
    call s:chansend("hide\n%d\n")
    let s:preview.is_hidden = v:true
  endif
endfunction

function! s:resize(columns, lines)
  if aerial_view#preview#active()
    call s:chansend("resize\n%d %d %d\n", a:columns, a:lines)
  endif
endfunction

function! s:move_resize(col_x, row_y, columns, lines)
  if aerial_view#preview#active()
    if s:preview.tmux.is_used
      let [offset_x, offset_y, _, _] = aerial_view#tmux#api#get_offset()
    else
      let [offset_x, offset_y] = [0, 0]
    endif
    call s:chansend("move_resize\n%d %d %d %d %d\n",
          \ offset_x + a:col_x, offset_y + a:row_y, a:columns, a:lines)
  endif
endfunction

function! s:hide_resize(col_x, row_y, columns, lines)
  if aerial_view#preview#active()
    if s:preview.tmux.is_used
      let [offset_x, offset_y, _, _] = aerial_view#tmux#api#get_offset()
    else
      let [offset_x, offset_y] = [0, 0]
    endif
    call s:chansend("hide_resize\n%d %d %d %d %d\n",
          \ offset_x + a:col_x, offset_y + a:row_y, a:columns, a:lines)
    let s:preview.is_hidden = v:true
  endif
endfunction

function! s:show()
  if aerial_view#preview#active() && s:preview.is_hidden
    call s:chansend("show\n%d\n")
    let s:preview.is_hidden = v:false
  endif
endfunction

function! s:reparent(windowid)
  if aerial_view#preview#active()
    call s:chansend("reparent\n%d %d\n", a:windowid)
  endif
endfunction
