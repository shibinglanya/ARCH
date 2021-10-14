let s:preview = {
  \ 'active':           v:false,
  \ 'main_path':        expand('<sfile>:h').'/../cxx/main',
  \ 'win_runtime_path': expand('<sfile>:h').'/preview_runtime.vim',
  \ }

function! s:timer_one(time, callback)
  return timer_start(a:time, a:callback, {'repeat': 1})
endfunction

function! s:timer_always(time, callback)
  return timer_start(a:time, a:callback, {'repeat': -1})
endfunction

function! s:timer_stop(timer)
  call timer_stop(a:timer)
endfunction

function! s:get_windowid()
  if tmux_util#is_used()
    return tmux_util#get_env('WINDOWID')
  endif
  return $WINDOWID
endfunction

function! preview#open(font, win_columns)
  if preview#active()
    return v:false
  endif
  if get(s:, 'old_columns', &columns) == &columns
    "提前调整，防止屏幕闪烁
    if &columns - &colorcolumn > a:win_columns
      let s:old_columns = &columns
      let &columns = &columns - a:win_columns
    endif
    call s:start_task_of_detecting_columns(a:win_columns)
  endif
  let s:preview.font = a:font
  let s:preview.win_columns = a:win_columns
  let command = [s:preview.main_path]
  let command = command + ['-font', a:font]
  let command = command + ['-embed', s:get_windowid()]
  let command = command + ['-config', s:preview.win_runtime_path]
  let command = command + ['--finish']
  let s:preview.job_id = jobstart(command, {'env':{'SERVERNAME': v:servername}})
  function! s:show_task(win_columns, timer)
    if preview#active()
      if get(s:, 'old_columns', &columns) != &columns
        call s:move_resize(&columns, 0, a:win_columns, &lines)
      else
        call s:resize(a:win_columns, &lines)
      endif
      call s:switch()
      call s:update_buffer(v:true)
      call s:update_cursor()
      if tmux_util#is_used()
        call tmux_util#unregister_hook('client-attached')
      endif
      call s:timer_stop(s:show_timer)
    endif
  endfunction
  let s:show_timer = s:timer_always(300, 
        \ function('s:show_task', [a:win_columns]))
  augroup AerialView_Preview
    autocmd!
    autocmd CursorMoved,CursorMovedI * call s:update_cursor()
    autocmd CursorHold,CursorHoldI * call s:update_buffer(v:false)
    autocmd BufEnter * call s:switch()
    autocmd TextChanged,TextChangedI * let b:is_modified = v:true
  augroup END
  return v:true
endfunction

function! preview#close(...) "在win_runtime.vim中会调用
  if !preview#active()
    return
  endif
  augroup AerialView_Preview
    autocmd!
  augroup END
  call preview#active(v:false)
  call jobstop(s:preview.job_id)
  if len(a:000) == 1 && type(a:1) == v:t_bool 
        \ && a:1 == v:true && tmux_util#is_used()
    call tmux_util#register_hook('client-attached', 
          \ function('preview#open', [s:preview.font, s:preview.win_columns]))
  else
    call s:stop_task_of_detecting_columns()
  endif
endfunction

function! preview#active(...) "在win_runtime.vim中会调用,以更新状态
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
  if buflisted(bufnr()) && exists(':SocketExec') && preview#active()
    let file_path = s:get_current_file_path()
    execute printf("SocketExec \"call Edit('%s')\"", file_path)
  endif
endfunction

function! s:update_cursor()
  if buflisted(bufnr()) && exists(':SocketExec') && preview#active()
    SocketExec "call Cursor(%d, %d, %s)", 
          \ line('w0'), line('w$'), getcurpos()
  endif
endfunction

function! s:update_buffer(bool)
  if !a:bool && get(b:, 'is_modified', v:false) == v:false
    return
  endif
  let b:is_modified = v:false
  if buflisted(bufnr()) && exists(':SocketExec') && preview#active()
    SocketExec "call UpateBuffer(%s)", string(getline(1, '$'))
  endif
endfunction

function! preview#get_info()
  return s:preview
endfunction

function! s:task_of_detecting_columns(win_columns, timer)
  let s:detected_columns = get(s:, 'detected_columns', &columns)
  if s:detected_columns != &columns
    "有足够的位置显示窗口
    if &columns - &colorcolumn > a:win_columns
      let s:detected_columns = &columns - a:win_columns
      let s:old_columns = &columns
      execute printf("set columns=%d", s:detected_columns)
      call s:move_resize(s:detected_columns, 0, a:win_columns, &lines)
    else
      call s:hide()
      let s:detected_columns = &columns
    endif
  endif
endfunction

function! s:start_task_of_detecting_columns(win_columns)
  let s:timer_id_of_detecting_columns = s:timer_always(100, 
        \ function('s:task_of_detecting_columns', [a:win_columns]))
endfunction

function! s:stop_task_of_detecting_columns()
  call timer_stop(get(s:, 'timer_id_of_detecting_columns', -1))
  "恢复&columns
  let old_columns = get(s:, 'old_columns', &columns)
  if old_columns != &columns
    execute printf("set columns=%d", old_columns)
  endif
endfunction

function! s:chansend(...)
  call chansend(s:preview.job_id, 
        \ function('printf', a:000 + [$CLIENTWINDOWID])())
endfunction

function! s:move(col_x, row_y)
  if preview#active()
    if tmux_util#is_used()
      let [offset_x, offset_y, _, _] = tmux_util#get_offset()
    else
      let [offset_x, offset_y] = [0, 0]
    endif
    call s:chansend("move\n%d %d %d\n", offset_x + a:col_x, offset_y + a:row_y)
  endif
endfunction

function! s:hide()
  if preview#active()
    call s:chansend("hide\n%d\n")
  endif
endfunction

function! s:resize(columns, lines)
  if preview#active()
    call s:chansend("resize\n%d %d %d\n", a:columns, a:lines)
  endif
endfunction

function! s:move_resize(col_x, row_y, columns, lines)
  if preview#active()
    if tmux_util#is_used()
      let [offset_x, offset_y, _, _] = tmux_util#get_offset()
    else
      let [offset_x, offset_y] = [0, 0]
    endif
    call s:chansend("move_resize\n%d %d %d %d %d\n",
          \ offset_x + a:col_x, offset_y + a:row_y, a:columns, a:lines)
  endif
endfunction

function! s:show()
  if preview#active()
    call s:chansend("show\n%d\n")
  endif
endfunction
