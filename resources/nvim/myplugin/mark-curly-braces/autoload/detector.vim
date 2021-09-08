let s:update_timer = {  }
function! s:update_timer.clone(winnr) abort
    call setwinvar(a:winnr, 'mcb_detector_update_id', 
                \ getwinvar(a:winnr, 'mcb_detector_update_id', -1) + 1)
    let l:other_timer       = copy(self)
    let l:other_timer.id    = getwinvar(a:winnr, 'mcb_detector_update_id', -1)
    let l:other_timer.winnr = a:winnr
    function! l:other_timer.task(mandatory, timer) abort
        if a:mandatory || self.id == getwinvar(self.winnr, 'mcb_detector_update_id', -1)
          call s:detector(a:mandatory)
        endif
    endfunction
    return l:other_timer
endfunction

function! MCB_DetectSign(timer)
  let signs1 = getbufvar(bufnr(), 'mcb_signals', [])
	let signs2 = sign_getplaced(bufnr(), {'group':'*'})[0].signs
  if signs2 != signs1
    call setbufvar(bufnr(), 'mcb_signals', signs2)
    doautocmd User MCB_SignChanged
  endif
endfunction

function! detector#init()
  let s:timer = timer_start(100, 'MCB_DetectSign', { 'repeat': -1 })
  let s:dict = s:update_timer.clone(winnr())
	augroup MarkCurlyBracesDetector
		autocmd!
    autocmd TextChanged,TextChangedI * 
          \ call setbufvar(bufnr(), 'mcb_flag', v:true) | call timer_start(60, function(s:dict.task, [v:true], s:dict), {'repeat': 1})
    autocmd CursorMoved,CursorMovedI * 
          \ call timer_start(60, function(s:dict.task, [v:false], s:dict), {'repeat': 1})
    autocmd BufEnter * call s:detector(v:true)
	augroup END
endfunction

let s:stack = {  }
let s:stack.container = [ ]
let s:stack.top = 0
function! s:stack.push(val)
  call insert(self.container, a:val, self.top)
  let self.top = self.top + 1
endfunction
function! s:stack.pop()
  let self.top = self.top - 1
  return self.container[self.top]
endfunction
function! s:stack.empty()
  return self.top == 0
endfunction

function! s:verify(lnum, col, filter_list)
  for pattern in a:filter_list
    if synIDattr(synID(a:lnum, a:col, 0), 'name') =~ pattern
      return v:false
    endif
  endfor
  return v:true
endfunction

function! s:searchpos(lines, pattern, filter_list)
  let result= []
  let [_, lnum, col, _] = matchstrpos(a:lines, a:pattern)
  while lnum != -1
    while col != -1
      if s:verify(lnum+1, col+1, a:filter_list)
        call add(result, [lnum, col])
      endif
      let col = match(a:lines[lnum], a:pattern, col+1)
    endwhile
    let [_, lnum, col, _] = matchstrpos(a:lines, a:pattern, lnum+1)
  endwhile
  return result
endfunction

function! s:detector(mandatory)
  if a:mandatory
    let view_lnum = 0
  else
    let view_lnum = getbufvar(bufnr(), 'mcb_view_lnum', 0)
  endif

  if view_lnum >= line('$') || line('.')+100 < view_lnum
    if !getbufvar(bufnr(), 'mcb_flag', v:false)
      doautocmd User MCB_CursorMoved
    endif
    return
  endif

  let view_lnum = min([line('$'), line('.')+300])
  let lines = getline('^', view_lnum)
  let list = s:searchpos(lines, '\v\{|\}', ['comment', 'character','string'])
  let result = []
  if !empty(list)
    for [lnum, col] in list
      if lines[lnum][col] == '{'
        call s:stack.push([lnum, col])
      elseif lines[lnum][col] == '}'
        call add(result, {'begin': s:stack.pop(), 'end': [lnum, col]})
      endif
    endfor
    while !s:stack.empty()
        call add(result, {'begin': s:stack.pop(), 'end': [view_lnum, 1]})
    endwhile
  endif
  call setbufvar(bufnr(), 'mcb_view_lnum', view_lnum)
  if getwinvar(winnr(), 'mcb_curly_braces_list', []) != result
    call setwinvar(winnr(), 'mcb_curly_braces_list', result)
    doautocmd User MCB_CurlyBracesListChanged
  endif
  call setbufvar(bufnr(), 'mcb_flag', v:false)
endfunction










