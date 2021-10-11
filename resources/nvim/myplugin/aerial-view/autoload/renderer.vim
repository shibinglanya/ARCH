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

function! s:is_valid_win(wid)
  if a:wid != -1 && nvim_win_is_valid(a:wid)
    return v:true
  endif
  return v:false
endfunction

function! s:is_valid_bufnr(bufnr)
  if a:bufnr != -1 && nvim_buf_is_valid(a:bufnr)
    return v:true
  endif
  return v:false
endfunction

function! s:close_win(wid)
  if s:is_valid_win(a:wid)
    call nvim_win_close(a:wid, 1)
  endif
endfunction

function! s:close_buf(bufnr)
endfunction

function! s:repeat_list(char, count)
  return split(repeat(a:char, a:count), '\zs')
endfunction

function! s:mcb_create_win(mcb_win, win_x, win_y, priority, lines)
  if !s:is_valid_bufnr(a:mcb_win.bufnr)
    let a:mcb_win.bufnr = s:create_buf()
  endif
  if s:is_valid_win(a:mcb_win.wid)
    call s:close_win(a:mcb_win.wid)
  endif

  let win_height = len(a:lines)
  let win_width  = max(map(copy(a:lines), 'strdisplaywidth(v:val)'))
  let a:mcb_win.wid = s:create_win(a:win_x, a:win_y, win_width, win_height, 
        \ a:mcb_win.bufnr, a:priority)
 "silent 屏蔽打印的消息 ---no lines in buffer ---
  silent call deletebufline(a:mcb_win.bufnr, 1, '$')
  call setbufline(a:mcb_win.bufnr, 1, a:lines)
endfunction

function! s:mcb_close_win(mcb_win)
  call s:close_win(a:mcb_win.wid)
  let a:mcb_win.wid        = -1
endfunction

function! s:render_win_in_middle(beg_height, end_height)
  let lines = s:repeat_list(' ', a:beg_height)
  let lines = lines + ['█']
  let lines = lines + s:repeat_list('█', a:end_height - a:beg_height - 1)
  let lines = lines + ['█']
  let mcb_win = w:view_renderer.win_in_middle
  call s:mcb_create_win(mcb_win, winwidth(winnr()), 0, 1, lines)
  call s:mcb_set_highlight(mcb_win)
endfunction

function! s:render_bottom_win(length)
  let mcb_win = w:view_renderer.bottom_win
  call s:mcb_create_win(mcb_win, 0, &lines, 1, [repeat('█', a:length)])
  call s:mcb_set_highlight(mcb_win)
endfunction

function! s:mcb_set_highlight(mcb_win)
  let hlname = 'ViewHighlight'
  if !hlexists(hlname)
    return
  endif
  for len in map(getbufline(a:mcb_win.bufnr, '^', '$'), 'len(v:val)')
    let idx = get(l:, 'idx', 0) + 1
    call win_execute(a:mcb_win.wid, printf(
        \'call matchaddpos("%s", [[%d, 1, %d]])', hlname, idx, len))
  endfor
endfunction

function! renderer#init()
  let w:view_renderer = {'win_in_middle': {'bufnr': -1, 'wid': -1},
        \'bottom_win': {'bufnr': -1, 'wid': -1}}
endfunction

function! renderer#render(lnum_beg, lnum_end, set_pos)
  call setpos('.', a:set_pos)
  normal zz
  let range = [a:lnum_beg-line('w0'), (line('w0')+winwidth(winnr()))-a:lnum_end]
  if get(s:, 'range', [-1, -1]) != range
    call s:mcb_close_win(w:view_renderer.win_in_middle)
    call s:render_win_in_middle(a:lnum_beg-line('w0'), a:lnum_end - line('w0'))
    let s:range = range
  endif
  let length = float2nr(floor((line('.')+0.0) / line('$') * winwidth(winnr())))
  if get(s:, 'length', -1) != length
    call s:mcb_close_win(w:view_renderer.bottom_win)
    call s:render_bottom_win(length+1)
    let s:length = length
  endif
endfunction
