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

function! s:renderer() abort
	let l:bufnr = bufnr()

  let [beg, end] = getwinvar(winnr(), 'mcb_curly_braces', [0, 0])

	let l:signs = sign_getplaced(l:bufnr, {'group':'*'})[0].signs
	let l:filter_self_signs = printf('\v^(%s|%s)\d+$', 
				\ s:sign_back_define.name, s:sign_front_define.name)
	let l:signs = filter(signs, {->v:val.name !~ l:filter_self_signs})
	let l:signs = filter(l:signs, {->v:val.lnum >= beg && v:val.lnum <= end})
  let b:sd_range = [beg, end]
  call sign_unplace(s:sign_back_define.group, {'buffer': l:bufnr})
  if [beg, end] != [0, 0]
    let s:place_flag = 0
    for line in range(max([beg, line('.')-100]), min([end, line('.')+100]))
      let b:sd_line = line
      doautocmd User SelfSignChanged
    endfor
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
