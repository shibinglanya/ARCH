augroup AerialViewScrollBar
  autocmd!
  autocmd CursorMoved * call s:update_scroll_bar()
augroup END

function! s:init()
  let w:scroll_bar = {}
  let w:scroll_bar.range = [-1, -1]
  let w:scroll_bar.bufnr = s:create_buf()
  let w:scroll_bar.wid = s:create_win(
      \ winwidth(winnr()), 0, 1, winheight(winnr()), w:scroll_bar.bufnr, 1)
endfunction

function! s:update_scroll_bar()
  let range = get(g:, 'scroll_bar_range', [-1, -1])
  if range == [-1, -1]
    return
  endif
  if !exists('w:scroll_bar')
    call s:init()
  endif
  let range = [range[0] - line('w0'), range[1] - line('w0')]
  if range != w:scroll_bar.range
    call s:set_highlight(range[0], range[1])
    let w:scroll_bar.range = range
  endif
endfunction

function! s:set_highlight(beg, end)
  sleep 1mm "没有这个，CPU频率会飙升...
  if !exists('s:ns_id')
    let s:ns_id = nvim_create_namespace('')
  endif
  if a:beg > w:scroll_bar.range[0] && a:beg < w:scroll_bar.range[1]
        \ && w:scroll_bar.range[1] > a:beg && w:scroll_bar.range[1] < a:end
    call nvim_buf_clear_namespace(
          \ w:scroll_bar.bufnr, s:ns_id, w:scroll_bar.range[0], a:beg)
    for idx in range(w:scroll_bar.range[1], a:end)
      call nvim_buf_add_highlight(w:scroll_bar.bufnr, 
            \ s:ns_id, "AerialViewScrollBar", idx, 0, 1)
    endfor
  elseif w:scroll_bar.range[0] > a:beg && w:scroll_bar.range[0] < a:end
        \ && a:end > w:scroll_bar.range[0] && a:end < w:scroll_bar.range[1]
    call nvim_buf_clear_namespace(
          \ w:scroll_bar.bufnr, s:ns_id, a:end+1, w:scroll_bar.range[1]+1)
    for idx in range(a:beg, w:scroll_bar.range[0]-1)
      call nvim_buf_add_highlight(w:scroll_bar.bufnr, 
            \ s:ns_id, "AerialViewScrollBar", idx, 0, 1)
    endfor
  else
    if w:scroll_bar.range != [-1, -1]
      call nvim_buf_clear_namespace(w:scroll_bar.bufnr, s:ns_id,
            \ w:scroll_bar.range[0], w:scroll_bar.range[1]+1)
    endif
    for idx in range(a:beg, a:end)
      call nvim_buf_add_highlight(w:scroll_bar.bufnr, 
            \ s:ns_id, "AerialViewScrollBar", idx, 0, 1)
    endfor
  endif
endfunction

function! s:create_win(win_x, win_y, width, height, bufnr, priority)
  let opts = {'relative': 'win', 'width': a:width, 'height': a:height,
      \ 'row': a:win_y, 'col': a:win_x, 'zindex': a:priority,
      \ 'anchor': 'NW', 'style': 'minimal', 'noautocmd': 1, 'focusable': 0}
  let wid = nvim_open_win(a:bufnr, 0, opts)
  call nvim_win_set_option(wid, 'winhl', 'Normal:MyHighlight')
  return wid
endfunction

function! s:repeat_list(char, count)
  return split(repeat(a:char, a:count), '\zs')
endfunction

function! s:create_buf()
  let bufnr = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(bufnr, 0, -1, v:true, [])
  call setbufline(bufnr, 1, s:repeat_list(' ', winheight(winnr())))
  return bufnr
endfunction
