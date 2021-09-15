if get(g:, 'mcb_debug_disabled', 0)
  let echo_file = '/tmp/mcb_debug.log'
  "call debug#display('renderer.vim', 's:close_xxx_win')
  execute debug#enter(expand('<sfile>'), expand('<slnum>') + 1, echo_file)
endif

"let g:sign_detector#default_priority = 99
"let g:sign_detector#id = 999
"
"let s:sign_back_define  = {
"			\ 'id': g:sign_detector#id, 
"			\ 'name': 'SignDetectorBack',
"			\ 'group': 'SignDetectorBackGroup',
"			\ 'priority': g:sign_detector#default_priority + 1
"			\}
"let s:sign_front_define = {
"			\ 'id': g:sign_detector#id, 
"			\ 'name': 'SignDetectorFront',
"			\ 'group': 'SignDetectorFrontGroup',
"			\ 'priority': g:sign_detector#default_priority + 2
"			\}
"
"function! renderer#place(text, texthl)
"	if exists('s:place_flag') && s:place_flag == 0
"		let id       = s:sign_back_define.id
"		let name     = s:sign_back_define.name
"		let group    = s:sign_back_define.group
"		let priority = s:sign_back_define.priority
"	elseif exists('s:place_flag') && s:place_flag == 1
"		let id       = s:sign_front_define.id
"		let name     = s:sign_front_define.name
"		let group    = s:sign_front_define.group
"		let priority = s:sign_front_define.priority
"	endif
"	call sign_define(name. b:sd_line, {'text': a:text, 'texthl': a:texthl})
"
"	call sign_place(id, group, name. b:sd_line, bufnr(), 
"				\ {'lnum': b:sd_line, 'priority': priority})
"endfunction

function! s:create_nvim_win(x, y, lines, priority)
  let bufnr = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(bufnr, 0, -1, v:true, a:lines)

  let height = len(a:lines)
  let width  = max(map(copy(a:lines), 'strdisplaywidth(v:val)'))
  let width  = width - 10 > 0 ? width : width 
  let opts = {'relative': 'win', 'width': width, 'height': height,
      \ 'row': a:y, 'col': a:x, 'zindex': a:priority,
      \ 'anchor': 'NW', 'style': 'minimal', 'noautocmd': 0, 'focusable': 0}
  let win = nvim_open_win(bufnr, 0, opts)

  call nvim_win_set_option(win, 'winhl', 'Normal:MyHighlight')
  return win
endfunction

function! s:create_win(x, y, lines, priority)
  let win =  s:create_nvim_win(a:x, a:y, a:lines, a:priority)
  return win
endfunction

function! s:render_win_above(beg)
  let numberwidth = max([&numberwidth - 1, len(line('$'))])
  let signs = s:get_signs()
  let prefix = eval('printf("'. s:get_sign_text(a:beg, signs).'%'. numberwidth. 'd ", '. a:beg. ')')
  let string = prefix. getline(a:beg)
  let mcb_win_above = get(w:, 'mcb_win_above', {})
  if !empty(mcb_win_above)
    if mcb_win_above.string == string
          \ && mcb_win_above.pos == line('w0')
      "由detect_sign触发Sign变更
      call s:update_sign(mcb_win_above.wid, signs, a:beg, len(prefix))
      return
    else
      call nvim_win_close(mcb_win_above.wid, 1)
    endif
  endif


  let lines = ['', '']
  let lines[0] = string.' ─╮'
  let lines[1] = ' ╭'.repeat('─', strdisplaywidth(lines[0])-3).'╯'

  "创建窗口
  let win = s:create_win(0, 0, lines, 2)
  call setwinvar(winnr(), 'mcb_win_above', {'wid': win, 'string': string, 'pos': line('w0')})
  "高亮
  for idx in range(len(getline(a:beg)))
    let col = idx + 1
    let name = synIDattr(synID(a:beg, col, 0), 'name')
    if empty(name) | continue | endif
    call win_execute(win, 
          \ 'call matchaddpos("'. name.'", [[1, '. (col+len(prefix)). ']])')
  endfor

  call s:update_sign(win, signs, a:beg, len(prefix))
endfunction


function! s:get_signs()
  let signs = sign_getplaced(bufnr(), {'group':'*'})[0].signs
  "过滤自身的sign
  "let signs =  filter(signs, {->v:val.id != g:sign_detector#id})
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


function! s:render_win_in_middle(beg, end)
  let mcb_win_in_middle = get(w:, 'mcb_win_in_middle', {})
  if !empty(mcb_win_in_middle)
    if mcb_win_in_middle.beg == a:beg-line('w0') && a:end-line('w0') == mcb_win_in_middle.end
      return
    else
      call nvim_win_close(mcb_win_in_middle.wid, 1)
    endif
  endif

  let lines = split('│'. repeat(',│', min([a:end, line('w$')])-a:beg), ',')
  "创建窗口
  let win = s:create_win(1, a:beg-line('w0'), lines, 1)
  let w:mcb_win_in_middle = {'wid': win, 'beg': a:beg-line('w0'), 'end': a:end-line('w0')}
endfunction

function! s:render_win_above2(beg)
  let mcb_win_above2 = get(w:, 'mcb_win_above2', {})
  if !empty(mcb_win_above2)
    if mcb_win_above2.pos == a:beg-line('w0')
          \ && mcb_win_above2.string == getline(a:beg)
          \ && mcb_win_above2.height == line('w$')
      return
    else
      call nvim_win_close(mcb_win_above2.wid, 1)
    endif
  endif

  let space_len = 0
  for char in split(getline(a:beg), '\zs')
    if char == ' '
      let space_len = space_len + 1
    elseif char == "\t"
      let space_len = space_len + &tabstop
    else
      break
    endif
  endfor

  let numberwidth = max([&numberwidth - 1, len(line('$'))])
  let lines = ['╭'.repeat('─', numberwidth+space_len)]
  "创建窗口
  let win = s:create_win(1, a:beg-line('w0'), lines, 2)
  let w:mcb_win_above2 = {'wid': win, 'pos': a:beg-line('w0'), 'height': line('w$'), 'string': getline(a:beg)}
endfunction

function! s:render_win_below2(end)
  let mcb_win_below2 = get(w:, 'mcb_win_below2', {})
  if !empty(mcb_win_below2)
    if mcb_win_below2.pos == a:end-line('w0')
          \ && mcb_win_below2.string == getline(a:end)
      return
    else
      call nvim_win_close(mcb_win_below2.wid, 1)
    endif
  endif

  let space_len = 0
  for char in split(getline(a:end), '\zs')
    if char == ' '
      let space_len = space_len + 1
    elseif char == "\t"
      let space_len = space_len + &tabstop
    else
      break
    endif
  endfor

  let numberwidth = max([&numberwidth - 1, len(line('$'))])
  let lines = ['╰'.repeat('─', numberwidth+space_len-1).'>']
  "创建窗口
  let win = s:create_win(1, a:end-line('w0'), lines, 2)
  let w:mcb_win_below2 = {'wid': win, 'pos': a:end-line('w0'), 'string': getline(a:end)}
endfunction

function! s:render_win_below(end)
  let string = ''.a:end
  let pos = line('w$')-line('w0')-2
  let mcb_win_below = get(w:, 'mcb_win_below', {})
  if !empty(mcb_win_below)
    if mcb_win_below.string == string && pos == mcb_win_below.pos
      return
    else
      call nvim_win_close(mcb_win_below.wid, 1)
    endif
  endif

  let numberwidth = max([&numberwidth - 1, len(line('$'))])
  let lines = ['', '', '']
  let lines[1] = eval('printf(" %'. numberwidth. 'd│", '. a:end. ')')
  let lines[0] = '╰'.repeat('─', strdisplaywidth(lines[1])-2).'╮'
  let lines[2] = '╭'.repeat('─', strdisplaywidth(lines[1])-2).'╯'

  "创建窗口
  let win = s:create_win(1, pos-1, lines, 2)
  let w:mcb_win_below = {'wid': win, 'string': string, 'pos': pos}
endfunction

function! MCB_ToggleWin()
  "let g:mcb_enable_win_above = (get(g:, 'mcb_enable_win_above', 1) + 1) % 2
  "let g:mcb_enable_win_below = (get(g:, 'mcb_enable_win_below', 1) + 1) % 2
  "call s:renderer()
endfunction

function! s:close_xxx_win(mcb_xxx_win)
  let winnr = winnr()
  let closed_winnr = win_id2win(expand('<afile>'))
  if closed_winnr != 0 && closed_winnr != winnr
    return
  endi
  let mcb_xxx_win = get(w:, a:mcb_xxx_win, {})
  if !empty(mcb_xxx_win)
    if nvim_win_is_valid(mcb_xxx_win.wid)
      call nvim_win_close(mcb_xxx_win.wid, 1)
    endif
    call setwinvar(winnr, a:mcb_xxx_win, {})
  endif
endfunction

function! s:renderer_aux(winnr, beg, end)
	let l:bufnr = bufnr()
  let [beg, end] = [a:beg, a:end]

	"let l:signs = sign_getplaced(l:bufnr, {'group':'*'})[0].signs
	"let l:filter_self_signs = printf('\v^(%s|%s)\d+$', 
	"			\ s:sign_back_define.name, s:sign_front_define.name)
	"let l:signs = filter(signs, {->v:val.name !~ l:filter_self_signs})
	"let l:signs = filter(l:signs, {->v:val.lnum >= beg && v:val.lnum <= end})
  "let b:sd_range = [beg, end]
  "call sign_unplace(s:sign_back_define.group, {'buffer': l:bufnr})
  let display_up = v:false
  let display_up2 = v:false
  let display_down = v:false
  let display_down2 = v:false
  if [beg, end] != [0, 0] && beg != end
    let s:place_flag = 0
    if line('w0') > beg
      call s:render_win_above(beg)
      let display_up = v:true
    else
      call s:render_win_above2(beg)
      let display_up2 = v:true
    endif
    if line('w$') < end
      call s:render_win_below(end)
      let display_down = v:true
    else
      call s:render_win_below2(end)
      let display_down2 = v:true
    endif
    call s:render_win_in_middle(max([beg, line('w0')]), min([end, line('w$')]))

    "for line in range(max([beg, line('w0')-50]), min([end, line('w$')+50]))
    "  let b:sd_line = line
    "  doautocmd User SelfSignChanged
    "endfor
  else
    call s:close_xxx_win('mcb_win_in_middle')
  endif
  if display_up == v:false
    call s:close_xxx_win('mcb_win_above')
  endif
  if display_up2 == v:false
    call s:close_xxx_win('mcb_win_above2')
  endif

  if display_down2 == v:false
    call s:close_xxx_win('mcb_win_below2')
  endif
  if display_down == v:false
    call s:close_xxx_win('mcb_win_below')
  endif

  "call sign_unplace(s:sign_front_define.group, {'buffer': l:bufnr})
  "let s:place_flag = 1
  "for sign_hidden in s:filter_low_priority(l:signs)
  "  let b:sd_range = [beg, end]
  "  let b:sd_sign = sign_hidden
  "  let b:sd_sign_defined = sign_getdefined(sign_hidden.name)[0]
  "  let b:sd_line = sign_hidden.lnum
  "  doautocmd User OtherSignHidden
  "endfor
endfunction

function! s:renderer()
  let [winnr, beg, end] = get(g:, 'mcb_curly_braces', [-1, 0, 0])
  if winnr == -1 | return | endif
  let winid = filter(getwininfo(), 'v:val.winnr == winnr')[0].winid
  call win_execute(winid, 'call s:renderer_aux(winnr, beg, end)')
endfunction

function! renderer#init()
	augroup MarkCurlyBracesRenderer
		autocmd!
    autocmd User MCB_CurlyBracesListChanged,MCB_SignChanged,MCB_CursorMoved
          \ call s:renderer()
    autocmd WinClosed * call s:close_xxx_win('mcb_win_above')
    autocmd WinClosed * call s:close_xxx_win('mcb_win_above2')
    autocmd WinClosed * call s:close_xxx_win('mcb_win_below')
    autocmd WinClosed * call s:close_xxx_win('mcb_win_below2')
    autocmd WinClosed * call s:close_xxx_win('mcb_win_in_middle')
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
