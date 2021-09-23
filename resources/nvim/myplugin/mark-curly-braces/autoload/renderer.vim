if get(g:, 'mcb_debug_disabled', 0)
  let echo_file = '/tmp/mcb_debug.log'
  call debug#display('renderer.vim', 's:mcb_create_win')
  "call debug#display('renderer.vim', 's:update_sign_of_win_above')
  execute debug#enter(expand('<sfile>'), expand('<slnum>') + 1, echo_file)
endif

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
  call deletebufline(a:mcb_win.bufnr, 1, '$')
  call setbufline(a:mcb_win.bufnr, 1, a:lines)
endfunction

function! s:mcb_close_win(mcb_win)
  call s:close_win(a:mcb_win.wid)
  let a:mcb_win.wid        = -1
endfunction

function! s:mcb_close_win_all()
  let winnr = winnr()
  let closed_winnr = win_id2win(expand('<afile>'))
  if closed_winnr != 0 && closed_winnr != winnr || !exists('w:mcb_renderer')
    return
  endif
  call s:mcb_close_win(w:mcb_renderer.win_in_middle)
  call s:mcb_close_win(w:mcb_renderer.win_above)
  call s:mcb_close_win(w:mcb_renderer.win_below)
endfunction

function! s:repeat_list(char, count)
  return split(repeat(a:char, a:count), '\zs')
endfunction

function! s:render_win_in_middle(beg_height, end_height)
  let lines = s:repeat_list(' ', a:beg_height)
  let lines = lines + s:repeat_list('│', a:end_height - a:beg_height + 1)
  let mcb_win = w:mcb_renderer.win_in_middle
  call s:mcb_create_win(mcb_win, 1, 0, 1, lines)
endfunction

function! s:get_padding_len(lnum, height)
  let line_of_screen = pos#get_screen_line_by_height_from_win(a:lnum, a:height)
  let space_len = strdisplaywidth(matchstr(line_of_screen, '\v^\s*'))
  let numberwidth = pos#get_numberwidth() - 1
  return space_len + numberwidth
endfunction

function! s:render_win_above2(lnum, height)
  let string = '╭'.repeat('─', s:get_padding_len(a:lnum, a:height))
  let mcb_win = w:mcb_renderer.win_above
  call s:mcb_create_win(mcb_win, 1, a:height, 2, [string])
endfunction

function! s:render_win_below2(lnum, height)
  let string = '╰'.repeat('─', s:get_padding_len(a:lnum, a:height) - 1).'>'
  let mcb_win = w:mcb_renderer.win_below
  call s:mcb_create_win(mcb_win, 1, a:height, 2, [string])
endfunction

function! s:render_win_above(lnum, col)
  let signs = s:get_signs()
  let numberwidth = pos#get_numberwidth() - 1
  let part1 = s:get_sign_text(a:lnum, signs)
        \ .eval('printf("%'. numberwidth. 'd ", '. a:lnum. ')')
  let part2 = pos#get_screen_line_by_bufcol(a:lnum, a:col)
  let lines = [part1. part2. ' ─╮'] 
  call add(lines, ' ╭'.repeat('─', strdisplaywidth(lines[0])-3).'╯')

  let mcb_win = w:mcb_renderer.win_above
  call s:mcb_create_win(mcb_win, 0, 0, 2, lines)

  ""高亮
  let heightofline = pos#get_screen_line_by_bufcol(a:lnum, a:col)
  let offset = len(join(pos#get_wrap_line(a:lnum)[: heightofline - 1], ''))
  let offset = offset - len(part2)
  for idx in range(len(part2))
    let col = idx + offset + 1
    let name = synIDattr(synID(a:lnum, col, 0), 'name')
    if empty(name) | continue | endif
    call win_execute(mcb_win.wid, 
          \ 'call matchaddpos("'. name.'", [[1, '. (idx+len(part1)+1). ']])')
  endfor

  call s:update_sign(mcb_win.wid, signs, a:lnum, len(part1))
endfunction

function! s:update_sign_of_win_above()
  let winid = b:mcb_detect_sign_val.winid
  let mcb_renderer = getwinvar(winid, 'mcb_renderer', {})
  if empty(mcb_renderer)
    return
  endif
  let [lnum, col] = [b:mcb_detect_sign_val.lnum, b:mcb_detect_sign_val.col]
  let mcb_win = mcb_renderer.win_above

  if s:is_valid_win(mcb_win.wid) 
        \ && !pos#beg_buf_pos2height_from_win(lnum, col)[1]
    call win_execute(winid, 'call s:render_win_above(lnum, col)')
  endif
endfunction

function! s:render_win_below(lnum, height)
  let numberwidth = pos#get_numberwidth() - 1
  let lines = ['', eval('printf(" %'. numberwidth. 'd│", '. a:lnum. ')'), '']
  let lines[0] = '╰'.repeat('─', strdisplaywidth(lines[1])-2).'╮'
  let lines[2] = '╭'.repeat('─', strdisplaywidth(lines[1])-2).'╯'

  let mcb_win = w:mcb_renderer.win_below
  let win = s:mcb_create_win(mcb_win, 1, a:height-3, 2, lines)
endfunction

"过滤优先级低的Sign
function! s:filter_low_priority(signs)
	if empty(a:signs) | return [] | endif
	let l:signs = sort(deepcopy(a:signs), {v1, v2->v1.lnum > v2.lnum})
	let result = [l:signs[0]]
	for idx in range(1, len(l:signs)-1)
		if l:signs[idx].lnum == result[-1].lnum
			if l:signs[idx].priority > result[-1].priority
				let result[-1] = l:signs[idx]
			endif
			continue
		endif
		call add(result, l:signs[idx])
	endfor
	return result
endfunction

function! s:get_signs()
  let signs = sign_getplaced(bufnr(), {'group':'*'})[0].signs
  let signs = s:filter_low_priority(signs)
  return signs
endfunction

function! s:update_sign(win, signs, lnum, len)
  for sign in a:signs
    if sign.lnum == a:lnum
      let sign_define = sign_getdefined(sign.name)[0]
      call win_execute(a:win, 
        \ 'call matchaddpos("'. sign_define.texthl .'", [[1, 1, '. a:len. ']])')
      return
    endif
  endfor
  call win_execute(a:win, 
    \ 'call matchaddpos("SignColumn", [[1, 1, '. a:len. ']])')
endfunction

function! s:get_sign_text(lnum, signs)
  for sign in a:signs
    if sign.lnum == a:lnum
      return sign_getdefined(sign.name)[0].text
    endif
  endfor
  return '  '
endfunction

function! renderer#toggle()
  let w:mcb_closed = (get(w:, 'mcb_closed', 0)+1)%2
  if w:mcb_closed == 1
    call s:mcb_close_win_all()
  else
    let g:mcb_curly_braces_winnr = winnr()
    call s:renderer(0)
  endif
endfunction

let s:update_timer = {  }
function! s:update_timer.clone(winnr, beg, end) abort
    call setwinvar(a:winnr, 'mcb_renderer_update_id', 
                \ getwinvar(a:winnr, 'mcb_renderer_update_id', -1) + 1)
    let l:other_timer       = copy(self)
    let l:other_timer.id    = getwinvar(a:winnr, 'mcb_renderer_update_id', -1)
    let l:other_timer.winnr = a:winnr
    let l:other_timer.mcb_beg = a:beg
    let l:other_timer.mcb_end = a:end
    function! l:other_timer.task(timer) abort
        if self.id == getwinvar(self.winnr, 'mcb_renderer_update_id', -1)
          try
            call win_execute(win_getid(self.winnr), 
                  \'call s:renderer_task(self.mcb_beg, self.mcb_end)')
          catch
          endtry
        endif
    endfunction
    return l:other_timer
endfunction

function! s:renderer_task(beg, end)
  if [a:beg[0], a:end[0]] != [0, 0] && a:beg[0] != a:end[0]
    let [beg_lnum, beg_col] = a:beg
    let [end_lnum, end_col] = a:end

    let [screen_beg, screen_end] = pos#buf_pos2height_from_win(
          \ beg_lnum, beg_col, end_lnum, end_col)
    if screen_beg[0] == v:true
      call s:render_win_above(beg_lnum, beg_col)
    else
      call s:render_win_above2(screen_beg[2], screen_beg[1])
    endif
    if screen_end[0] == v:true
      call s:render_win_below(end_lnum, screen_end[1])
    else
      call s:render_win_below2(screen_end[2], screen_end[1])
    endif
    call s:render_win_in_middle(screen_beg[1], screen_end[1])
  else
    call s:mcb_close_win_all()
  endif
endfunction

function! s:run_timer_task(winnr, beg, end, delay)
  call timer_start(a:delay, 
        \ s:update_timer.clone(a:winnr, a:beg, a:end).task, {'repeat': 1})
  "call win_execute(win_getid(a:winnr), 
  "      \'call s:renderer_task(a:beg, a:end)')
endfunction

function! s:renderer(delay)
  let winnr = get(g:, 'mcb_curly_braces_winnr', 0)
  if getwinvar(winnr, 'mcb_closed', 0) == 1
    return
  endif
  let mcb_curly_braces = getwinvar(winnr, 'mcb_curly_braces', {})
  let beg = mcb_curly_braces.beg
  let end = mcb_curly_braces.end
  call win_execute(win_getid(winnr), 'call s:mcb_close_win_all()')
  call s:run_timer_task(winnr, beg, end, a:delay)
endfunction

function! s:init()
  let w:mcb_renderer = {
        \'win_above':     {'bufnr': -1, 'wid': -1},
        \'win_below':     {'bufnr': -1, 'wid': -1},
        \'win_in_middle': {'bufnr': -1, 'wid': -1},
        \}
endfunction

function! renderer#init()
	augroup MarkCurlyBracesRenderer
		autocmd!
    autocmd User MCB_CurlyBracesListChanged,MCB_CursorMoved call s:renderer(500)
    autocmd User MCB_SignChanged call s:update_sign_of_win_above()
    autocmd WinClosed * call s:mcb_close_win_all()
    autocmd WinNew,VimEnter  * call s:init()
	augroup END
endfunction
