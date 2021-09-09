
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


function! s:flags(flags)
  let is_left = index(split(a:flags, '\zs'), 'b') != -1 ? v:true : v:false
  let c = getline('.')[col('.') - 1]
  if is_left
    return a:flags. (c == '{' ? 'c' : '')
  else
    return a:flags. (c == '}' ? 'c' : '')
  endif
endfunction

function! s:searchpair(start, middle, end, flags)
  let save_cursor = getcurpos()
  let [lnum, col] = searchpairpos(a:start, a:middle, a:end, s:flags(a:flags.'zW'))
  while [lnum, col] != [0, 0] 
        \ && synIDattr(synID(lnum, col, 0), 'name') =~ '\vcomment|string'
    let new_cursor = copy(save_cursor)
    let new_cursor[1] = lnum
    let new_cursor[2] = col
    call setpos('.', new_cursor)
    let [lnum, col] = searchpairpos(a:start, a:middle, a:end, a:flags.'zW')
  endwhile
  call setpos('.', save_cursor)
  return lnum
endfunction

function! s:detector()
  let beg_lnum = s:searchpair('{', '', '}', 'b')
  let end_lnum = s:searchpair('{', '', '}', '')

  if beg_lnum == 0 || end_lnum == 0 || beg_lnum > end_lnum
    let beg_lnum = 0
    let end_lnum = 0
  endif
  
  let mcb_curly_braces = getwinvar(winnr(), 'mcb_curly_braces', [0, 0])
  if mcb_curly_braces[0] != beg_lnum || mcb_curly_braces[1] != end_lnum
    call setwinvar(winnr(), 'mcb_curly_braces', [beg_lnum, end_lnum]) 
    doautocmd User MCB_CurlyBracesListChanged
  else
    doautocmd User MCB_CursorMoved
  endif
  return
endfunction

