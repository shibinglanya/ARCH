if get(g:, 'mcb_debug_disabled', 0)
  let echo_file = '/tmp/mcb_debug.log'
  "call debug#display('renderer.vim', 's:rowpos2winpos')
  call debug#display('renderer.vim', 's:update_sign_of_win_above')
  execute debug#enter(expand('<sfile>'), expand('<slnum>') + 1, echo_file)
endif

function! s:create_win(win_x, win_y, width, height, bufnr, priority)
  let opts = {'relative': 'win', 'width': a:width, 'height': a:height,
      \ 'row': a:win_y, 'col': a:win_x, 'zindex': a:priority,
      \ 'anchor': 'NW', 'style': 'minimal', 'noautocmd': 0, 'focusable': 0}
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

function! s:close_win(wid)
  if s:is_valid_win(a:wid)
    call nvim_win_close(a:wid, 1)
  endif
endfunction

function! s:close_buf(bufnr)
endfunction

function! s:set_width_of_win(wid, width)
  call nvim_win_set_width(a:wid, a:width)
endfunction

function! s:set_height_of_win(wid, height)
  call nvim_win_set_height(a:wid, a:height)
endfunction

function! s:get_position_of_win(wid)
  return nvim_win_get_position(a:wid)
endfunction

function! s:repeat_list(char, count)
  return split(repeat(a:char, a:count), '\zs')
endfunction

function! s:lnum2height_of_screen(lnum, col)
  if &wrap == v:true
    return screenpos(winnr(), a:lnum, a:col).row
  endif
  return a:lnum
endfunction

function! s:get_numberwidth()
  return &number ? max([&numberwidth, strdisplaywidth(line('$'))+1]) : 0
endfunction

function! s:get_wrap_line(lnum)
  if &wrap == v:false | return [getline(a:lnum)] | endif
  let result = ['']
  let win_width = winwidth(winnr()) - s:get_numberwidth() - 2
  let display_width = 0
  for char in split(getline(a:lnum), '\zs')
    let display_width = display_width + strdisplaywidth(char)
    if display_width >= win_width
      let result[-1] = result[-1].char
      call add(result, '')
      let display_width = 0
      continue
    endif
    let result[-1] = result[-1].char
  endfor
  return result
endfunction

function! s:lnum2height_of_line(lnum, col)
  let len = 0
  let height = 1
  for line in s:get_wrap_line(a:lnum)
    let len = len + len(line)
    if a:col <= len
      return height
    endif
    let height = height + 1
  endfor
endfunction

function! s:get_line_of_screen(lnum, height)
  if a:lnum == line('w$')+1
    let height = s:lnum2height_of_screen(a:lnum-1, 1)
          \ + s:lnum2height_of_line(a:lnum-1, len(getline(a:lnum-1)))
  else
    let height = s:lnum2height_of_screen(a:lnum, 1)
  endif
  return s:get_wrap_line(a:lnum)[a:height - height]
endfunction

function! s:get_line_of_screen_by_col(lnum, col)
  return s:get_wrap_line(a:lnum)[s:lnum2height_of_line(a:lnum, a:col) - 1]
endfunction

function! renderer#test(lnum, height)
  return s:get_line_of_screen(a:lnum, a:height)
endfunction

function! s:mcb_create_win(mcb_win, win_x, win_y, width, height, priority)
  if s:is_valid_win(a:mcb_win.wid)
    call s:close_win(a:mcb_win.wid)
  endif
  let a:mcb_win.wid = s:create_win(a:win_x, a:win_y, a:width, a:height, 
        \ a:mcb_win.bufnr, a:priority)
  let a:mcb_win.size = [a:width, a:height]
endfunction

function! s:mcb_close_win(mcb_win)
  call s:close_win(a:mcb_win.wid)
  let a:mcb_win.wid        = -1
endfunction

function! s:rowpos2winpos(beg, end)
  let [beg_lnum, beg_col] = a:beg
  let [end_lnum, end_col] = a:end
  let screen_1 = s:lnum2height_of_screen(line('w0'), 1)
  if beg_lnum >= line('w0')
    let screen_beg = [v:true, s:lnum2height_of_screen(beg_lnum, beg_col), beg_lnum]
  else
    let screen_beg = 
          \ [v:false, s:lnum2height_of_screen(line('w0'), 1), line('w0')]
  endif
  if end_lnum <= line('w$')
    let screen_end = [v:true, s:lnum2height_of_screen(end_lnum, end_col), end_lnum]
  else
    let height = win_screenpos(winnr())[0] + winheight(winnr()) - 1
    let screen_end = s:lnum2height_of_screen(line('w$'), len(getline('w$')))
    if screen_end != height "有未填充的行
      if end_lnum == line('w$')+1
        let screen_end = 
              \ screen_end + s:lnum2height_of_line(line('w$')+1, end_col)
        if screen_end <= height
          let screen_end = [v:true, screen_end, end_lnum]
        else
          let screen_end = [v:false, height, end_lnum]
        endif
      else
        let screen_end = [v:false, height, line('w$')+1]
      endif
    else
      let screen_end = [v:false, screen_end, line('w$')]
    endif
  endif
  return [screen_beg, screen_end]
endfunction

function! s:render_win_in_middle(screen_beg, screen_end)
  let mcb_win = w:mcb_renderer.win_in_middle
  call deletebufline(mcb_win.bufnr, 1, '$')
  let [width, height] = [1, winheight(winnr())]
  call s:mcb_create_win(mcb_win, 1, 0, width, height, 1)
  let screen_1   = s:lnum2height_of_screen(line('w0'), 1)
  let lines = s:repeat_list(' ', a:screen_beg - screen_1)
  let lines = lines + s:repeat_list('│', a:screen_end - a:screen_beg + 1)
  call setbufline(mcb_win.bufnr, 1, lines)
endfunction

function! s:render_win_above2(lnum, screen_beg)
  let mcb_win = w:mcb_renderer.win_above
  let string_of_screen = s:get_line_of_screen(a:lnum, a:screen_beg)
  let space_len = strdisplaywidth(matchstr(string_of_screen, '\v^\s*'))
  let numberwidth = s:get_numberwidth() - 1
  let string = '╭'.repeat('─', numberwidth+space_len)
  let [width, height] = [strdisplaywidth(string), 1]
  let screen_1 = s:lnum2height_of_screen(line('w0'), 1)
  call s:mcb_create_win(mcb_win, 1, a:screen_beg - screen_1, width, height, 2)
  call deletebufline(mcb_win.bufnr, 1, '$')
  call setbufline(mcb_win.bufnr, 1, string)
endfunction

function! s:render_win_below2(lnum, screen_end)
  let mcb_win = w:mcb_renderer.win_below
  let string_of_screen = s:get_line_of_screen(a:lnum, a:screen_end)
  let space_len = strdisplaywidth(matchstr(string_of_screen, '\v^\s*'))
  let numberwidth = s:get_numberwidth() - 1
  let string = '╰'.repeat('─', numberwidth+space_len-1)
        \ .((space_len+numberwidth+1)!=0?'>':'')
  let [width, height] = [strdisplaywidth(string), 1]
  let screen_1 = s:lnum2height_of_screen(line('w0'), 1)
  call s:mcb_create_win(mcb_win, 1, a:screen_end - screen_1, width, height, 2)
  call deletebufline(mcb_win.bufnr, 1, '$')
  call setbufline(mcb_win.bufnr, 1, string)
endfunction

function! s:render_win_above(lnum, col)
  let numberwidth = s:get_numberwidth() - 1
  let signs = s:get_signs()
  let string1 = s:get_sign_text(a:lnum, signs)
  let string1 = string1. eval('printf("%'. numberwidth. 'd ", '. a:lnum. ')')
  let string2 = s:get_line_of_screen_by_col(a:lnum, a:col)
  let string = string1. string2

  let lines = ['', '']
  let lines[0] = string.' ─╮'
  let lines[1] = ' ╭'.repeat('─', strdisplaywidth(lines[0])-3).'╯'

  let mcb_win = w:mcb_renderer.win_above
  call s:mcb_create_win(mcb_win, 0, 0, strdisplaywidth(lines[1]), 2, 2)
  call deletebufline(mcb_win.bufnr, 1, '$')
  call setbufline(mcb_win.bufnr, 1, lines)

  let heightofline = s:lnum2height_of_line(a:lnum, a:col)
  let offset = len(join(s:get_wrap_line(a:lnum)[: heightofline - 1], ''))
  let offset = offset - len(string2)

  "高亮
  for idx in range(len(string2))
    let col = idx + offset + 1
    let name = synIDattr(synID(a:lnum, col, 0), 'name')
    if empty(name) | continue | endif
    call win_execute(mcb_win.wid, 
          \ 'call matchaddpos("'. name.'", [[1, '. (idx+len(string1)+1). ']])', 'silent!')
  endfor

  call s:update_sign(mcb_win.wid, signs, a:lnum, len(string1))
endfunction

function! s:render_win_below(lnum, screen_end)
  let numberwidth = s:get_numberwidth() - 1
  let lines = ['', '', '']
  let lines[1] = eval('printf(" %'. numberwidth. 'd│", '. a:lnum. ')')
  let lines[0] = '╰'.repeat('─', strdisplaywidth(lines[1])-2).'╮'
  let lines[2] = '╭'.repeat('─', strdisplaywidth(lines[1])-2).'╯'

  let mcb_win = w:mcb_renderer.win_below
  let screen_1 = s:lnum2height_of_screen(line('w0'), 1)
  let win = s:mcb_create_win(mcb_win, 1, a:screen_end-screen_1-3, len(lines[1]), 3, 2)
  call deletebufline(mcb_win.bufnr, 1, '$')
  call setbufline(mcb_win.bufnr, 1, lines)
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
        \ 'call matchaddpos("'. sign_define.texthl .'", [[1, 1, '. a:len. ']])', 'silent!')
      return
    endif
  endfor
  call win_execute(a:win, 
    \ 'call matchaddpos("SignColumn", [[1, 1, '. a:len. ']])', 'silent!')
endfunction


function! s:get_sign_text(lnum, signs)
  for sign in a:signs
    if sign.lnum == a:lnum
      return sign_getdefined(sign.name)[0].text
    endif
  endfor
  return '  '
endfunction

function! MCB_ToggleWin()
  "let g:mcb_enable_win_above = (get(g:, 'mcb_enable_win_above', 1) + 1) % 2
  "let g:mcb_enable_win_below = (get(g:, 'mcb_enable_win_below', 1) + 1) % 2
  "call s:renderer()
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
          call win_execute(win_getid(self.winnr), 
                \'call s:renderer_task(self.mcb_beg, self.mcb_end)', 'silent!')
          "call win_gotoid(win_getid(winnr()))
        endif
    endfunction
    return l:other_timer
endfunction

function! s:renderer_task(beg, end)
  if [a:beg[0], a:end[0]] != [0, 0] && a:beg[0] != a:end[0]
    let [beg_lnum, beg_col] = a:beg
    let [end_lnum, end_col] = a:end
    let [screen_beg, screen_end] = s:rowpos2winpos(a:beg, a:end)
    if screen_beg[0] == v:true
      call s:render_win_above2(screen_beg[2], screen_beg[1])
    else
      call s:render_win_above(beg_lnum, beg_col)
    endif
    if screen_end[0] == v:true
      call s:render_win_below2(screen_end[2], screen_end[1])
    else
      call s:render_win_below(end_lnum, screen_end[1])
    endif
    call s:render_win_in_middle(screen_beg[1], screen_end[1])
  else
    call s:mcb_close_win_all()
  endif
endfunction

function! s:mcb_close_win_all()
  let winnr = winnr()
  let closed_winnr = win_id2win(expand('<afile>'))
  if closed_winnr != 0 && closed_winnr != winnr
    return
  endif
  call s:mcb_close_win(w:mcb_renderer.win_in_middle)
  call s:mcb_close_win(w:mcb_renderer.win_above)
  call s:mcb_close_win(w:mcb_renderer.win_below)
endfunction

function! s:run_timer_task(winnr, beg, end)
  "call timer_start(500, 
  "      \ s:update_timer.clone(a:winnr, a:beg, a:end).task, {'repeat': 1})
  call win_execute(win_getid(a:winnr), 
        \'call s:renderer_task(a:beg, a:end)', 'silent!')
endfunction

function! s:renderer()
  let winnr = get(g:, 'mcb_curly_braces_winnr', 0)
  let mcb_curly_braces = getwinvar(winnr, 'mcb_curly_braces', {})
  let beg = mcb_curly_braces.beg
  let end = mcb_curly_braces.end
  call win_execute(win_getid(winnr), 'call s:mcb_close_win_all()', 'silent!')
  if [beg[0], end[0]] != [0, 0] && beg[0] != end[0]
    call s:run_timer_task(winnr, beg, end)
  endif
endfunction

function! s:init()
  let w:mcb_renderer = {'win_above':{}, 'win_below':{}, 'win_in_middle':{}}
  let w:mcb_renderer.win_above.bufnr      = s:create_buf()
  let w:mcb_renderer.win_above.wid        = -1

  let w:mcb_renderer.win_below.bufnr      = s:create_buf()
  let w:mcb_renderer.win_below.wid        = -1

  let w:mcb_renderer.win_in_middle.bufnr      = s:create_buf()
  let w:mcb_renderer.win_in_middle.wid        = -1
endfunction

function! s:update_sign_of_win_above()
  let mcb_win = getwinvar(b:mcb_signs_winid, 'mcb_renderer', {})
  if empty(mcb_win) | return | endif
  let mcb_win = mcb_win.win_above
  if s:is_valid_win(mcb_win.wid) 
        \ && !s:rowpos2winpos(b:mcb_signs_lnum_and_col, [1,1])[0][0] "不要忘记优化这里
    let [beg_lnum, beg_col] = b:mcb_signs_lnum_and_col
    call win_execute(b:mcb_signs_winid, 
          \ 'call s:render_win_above(beg_lnum, beg_col)')
  endif
endfunction

function! renderer#init()
	augroup MarkCurlyBracesRenderer
		autocmd!
    autocmd User MCB_CurlyBracesListChanged,MCB_CursorMoved
          \ call s:renderer()
    autocmd User MCB_SignChanged call s:update_sign_of_win_above()
    autocmd WinClosed * call s:mcb_close_win_all()
    autocmd WinNew,VimEnter  * call s:init()
	augroup END
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
