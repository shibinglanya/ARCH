if get(g:, 'mcb_debug_disabled', 0)
  let echo_file = '/tmp/mcb_debug.log'
  execute debug#enter(expand('<sfile>'), expand('<slnum>') + 1, echo_file)
endif

let g:sign_detector#default_priority = 99
let g:sign_detector#id = 999

let s:sign_back_define  = {
			\ 'id': g:sign_detector#id, 
			\ 'name': 'SignDetectorBack',
			\ 'group': 'SignDetectorBackGroup',
			\ 'priority': g:sign_detector#default_priority + 1
			\}
let s:sign_front_define = {
			\ 'id': g:sign_detector#id, 
			\ 'name': 'SignDetectorFront',
			\ 'group': 'SignDetectorFrontGroup',
			\ 'priority': g:sign_detector#default_priority + 2
			\}

function! renderer#place(text, texthl)
	if exists('s:place_flag') && s:place_flag == 0
		let id       = s:sign_back_define.id
		let name     = s:sign_back_define.name
		let group    = s:sign_back_define.group
		let priority = s:sign_back_define.priority
	elseif exists('s:place_flag') && s:place_flag == 1
		let id       = s:sign_front_define.id
		let name     = s:sign_front_define.name
		let group    = s:sign_front_define.group
		let priority = s:sign_front_define.priority
	endif
	call sign_define(name. b:sd_line, {'text': a:text, 'texthl': a:texthl})

	call sign_place(id, group, name. b:sd_line, bufnr(), 
				\ {'lnum': b:sd_line, 'priority': priority})
endfunction



function! s:create_nvim_win(lnum, row, string)
  let info = a:string.'│'
  let info_len = strdisplaywidth(info)+2
  let buf = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(buf, 0, -1, v:true, 
        \ ['╰'.repeat('─', info_len-4).'╮', info, '╭'.repeat('─', info_len-4).'╯'])
  let opts = {'relative': 'win', 'width': info_len-2, 'height': 3, 'col': 0,
      \ 'row': a:row, 'anchor': 'NW', 'style': 'minimal', 'noautocmd': 0}
  let win = nvim_open_win(buf, 0, opts)
  call nvim_win_set_option(win, 'winhl', 'Normal:MyHighlight')
  return win
endfunction

function! s:get_signs()
  let signs = sign_getplaced(bufnr(), {'group':'*'})[0].signs
  "过滤自身的sign
  let signs =  filter(signs, {->v:val.id != g:sign_detector#id})
  let signs = s:filter_low_priority(signs)
  return signs
endfunction

function! s:update_sign(win, signs, lnum, len)
  for sign in a:signs
    if sign.lnum == a:lnum
      let sign_define = sign_getdefined(sign.name)[0]
      call win_execute(a:win, 
        \ 'call matchaddpos("'. sign_define.texthl .'", [[2, 1, '. a:len. ']])')
      return
    endif
  endfor
  call win_execute(a:win, 
    \ 'call matchaddpos("SignColumn", [[2, 1, '. a:len. ']])')
endfunction

function! s:get_sign_text(lnum, signs)
  for sign in a:signs
    if sign.lnum == a:lnum
      return sign_getdefined(sign.name)[0].text
    endif
  endfor
  return '  '
endfunction

function! s:render_up_win(beg)
  let max_lnum_len = len(line('$'))
  let numberwidth = &numberwidth - 1
  let numberwidth = max_lnum_len > numberwidth ? max_lnum_len : numberwidth
  let signs = s:get_signs()
  let prefix = eval('printf("'. s:get_sign_text(a:beg, signs).'%'. numberwidth. 'd ", '. a:beg. ')')
  let string = prefix. getline(a:beg)
  let mcb_up_win = get(w:, 'mcb_up_win', {})
  if !empty(mcb_up_win)
    if mcb_up_win.string == string
      "由MCB_SignChanged触发Sign变更
      call s:update_sign(mcb_up_win.wid, signs, a:beg, len(prefix))
      return
    else
      call nvim_win_close(mcb_up_win.wid, 1)
    endif
  endif


  "创建窗口
  let win = s:create_nvim_win(a:beg, 0, string)
  call setwinvar(winnr(), 'mcb_up_win', {'wid': win, 'string': string})
  "高亮
  for idx in range(len(getline(a:beg)))
    let col = idx + 1
    let name = synIDattr(synID(a:beg, col, 0), 'name')
    if empty(name) | continue | endif
    call win_execute(win, 
          \ 'call matchaddpos("'. name.'", [[2, '. (col+len(prefix)). ']])')
  endfor

  call s:update_sign(win, signs, a:beg, len(prefix))
endfunction


function! s:render_down_win(end)
  let string = ''.a:end
  let mcb_down_win = get(w:, 'mcb_down_win', {})
  if !empty(mcb_down_win)
    if mcb_down_win.string == string
      return
    else
      call nvim_win_close(mcb_down_win.wid, 1)
    endif
  endif
  "创建窗口
  let win = s:create_nvim_win(a:end, line('w$')-line('w0')-2, string)
  let w:mcb_down_win = {'wid': win, 'string': string}
endfunction

function! s:close_up_win()
  let mcb_up_win = get(w:, 'mcb_up_win', {})
  if !empty(mcb_up_win)
    call nvim_win_close(mcb_up_win.wid, 1)
    let w:mcb_up_win = {}
  endif
endfunction

function! s:close_down_win()
  let mcb_down_win = get(w:, 'mcb_down_win', {})
  if !empty(mcb_down_win)
    call nvim_win_close(mcb_down_win.wid, 1)
    let w:mcb_down_win = {}
  endif
endfunction


function! s:renderer() abort
	let l:bufnr = bufnr()
  let [beg, end] = get(w:, 'mcb_curly_braces', [0, 0])

	let l:signs = sign_getplaced(l:bufnr, {'group':'*'})[0].signs
	let l:filter_self_signs = printf('\v^(%s|%s)\d+$', 
				\ s:sign_back_define.name, s:sign_front_define.name)
	let l:signs = filter(signs, {->v:val.name !~ l:filter_self_signs})
	let l:signs = filter(l:signs, {->v:val.lnum >= beg && v:val.lnum <= end})
  let b:sd_range = [beg, end]
  call sign_unplace(s:sign_back_define.group, {'buffer': l:bufnr})
  let display_up = v:false
  let display_down = v:false
  if [beg, end] != [0, 0]
    let s:place_flag = 0
    if line('w0') > beg
      call s:render_up_win(beg)
      let display_up = v:true
    endif
    if line('w$') < end
      call s:render_down_win(end)
      let display_down = v:true
    endif
    for line in range(max([beg, line('w0')-50]), min([end, line('w$')+50]))
      let b:sd_line = line
      doautocmd User SelfSignChanged
    endfor
  endif
  if display_up == v:false
    call s:close_up_win()
  endif
  if display_down == v:false
    call s:close_down_win()
  endif

  call sign_unplace(s:sign_front_define.group, {'buffer': l:bufnr})
  let s:place_flag = 1
  for sign_hidden in s:filter_low_priority(l:signs)
    let b:sd_range = [beg, end]
    let b:sd_sign = sign_hidden
    let b:sd_sign_defined = sign_getdefined(sign_hidden.name)[0]
    let b:sd_line = sign_hidden.lnum
    doautocmd User OtherSignHidden
  endfor
endfunction





function! renderer#init()
	augroup MarkCurlyBracesRenderer
		autocmd!
    autocmd User MCB_CurlyBracesListChanged,MCB_SignChanged,MCB_CursorMoved call s:renderer()
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
