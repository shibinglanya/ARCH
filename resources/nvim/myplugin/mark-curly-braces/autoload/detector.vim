
let s:update_timer = {  }
function! s:update_timer.clone(winnr) abort
    call setwinvar(a:winnr, 'mcb_detector_update_id', 
                \ getwinvar(a:winnr, 'mcb_detector_update_id', -1) + 1)
    let l:other_timer       = copy(self)
    let l:other_timer.id    = getwinvar(a:winnr, 'mcb_detector_update_id', -1)
    let l:other_timer.winnr = a:winnr
    function! l:other_timer.task(timer) abort
        if self.id == getwinvar(self.winnr, 'mcb_detector_update_id', -1)
          call s:detector()
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
  
	augroup MarkCurlyBracesDetector
		autocmd!
    autocmd CursorMoved,CursorMovedI * 
          \ call timer_start(60, s:update_timer.clone(winnr()).task, {'repeat': 1})
    autocmd BufEnter * call s:detector()
	augroup END
endfunction

function! s:matchstrpos(string, pat)
  let result= []
  let idx = 0
  let idx = match(a:string, a:pat, idx)
  while idx != -1
    call add(result, idx)
    let idx = match(a:string, a:pat, idx+1)
  endwhile
  return reverse(result)
endfunction

function! s:is_valid_curly_braces(lnum, col, beg_lnum, beg_col, end_lnum, end_col)
  if a:beg_lnum == a:lnum && a:end_lnum == a:lnum
    if a:col >= a:beg_col && a:col <= a:end_col
      return v:true
    endif
  elseif a:beg_lnum == a:lnum && a:col >= a:beg_col
    return v:true
  elseif a:end_lnum == a:lnum && a:col <= a:end_col
    return v:true
  elseif a:lnum > a:beg_lnum && a:lnum < a:end_lnum
    return v:true
  endif
  return v:false
endfunction

function! s:detector()
  let [lnum, col] = [line('.'), col('.')]
  let lines = getline('^', lnum)
  let lines[-1] = lines[-1][0:col-1]
  for idx in range(len(lines)-1, 0, -1)
    let beg_lnum = idx + 1
    for idx in s:matchstrpos(lines[idx], '\V{')
      let beg_col = idx + 1
      let save_cursor = getcurpos()
      let new_cursor = copy(save_cursor)
      let new_cursor[1] = beg_lnum
      let new_cursor[2] = beg_col
      call setpos('.', new_cursor)
      let [end_lnum, end_col] = searchpairpos('{', '', '}', 'n')
      call setpos('.', save_cursor)
      if s:is_valid_curly_braces(lnum, col, beg_lnum, beg_col, end_lnum, end_col)
        let mcb_curly_braces = getwinvar(winnr(), 'mcb_curly_braces', [0, 0])
        if mcb_curly_braces[0] != beg_lnum || mcb_curly_braces[1] != end_lnum
          call setwinvar(winnr(), 'mcb_curly_braces', [beg_lnum, end_lnum]) 
          doautocmd User MCB_CurlyBracesListChanged
        else
          doautocmd User MCB_CursorMoved
        endif
        return
      endif
    endfor
  endfor
  call setwinvar(winnr(), 'mcb_curly_braces', [0, 0]) 
  doautocmd User MCB_CurlyBracesListChanged
endfunction










