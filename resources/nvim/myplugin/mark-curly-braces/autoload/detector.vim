if get(g:, 'mcb_debug_disabled', 0)
  let echo_file = '/tmp/mcb_debug.log'
  call debug#display('detector.vim', 's:detector')
  execute debug#enter(expand('<sfile>'), expand('<slnum>') + 1, echo_file)
endif

let s:update_timer = {  }
function! s:update_timer.clone(winnr, mandatory) abort
    call setwinvar(a:winnr, 'mcb_detector_update_id', 
                \ getwinvar(a:winnr, 'mcb_detector_update_id', -1) + 1)
    let l:other_timer       = copy(self)
    let l:other_timer.id    = getwinvar(a:winnr, 'mcb_detector_update_id', -1)
    let l:other_timer.winnr = a:winnr
    let l:other_timer.mandatory = a:mandatory
    function! l:other_timer.task(timer) abort
        let winid = win_getid(self.winnr)
        if self.id == getwinvar(self.winnr, 'mcb_detector_update_id', -1)
          call win_execute(winid, 'call s:detector(self.winnr, self.mandatory)')
          return
        endif
        let mcb_curly_braces = getwinvar(self.winnr, 'mcb_curly_braces', {})
        if !empty(mcb_curly_braces) && [line('w0'), line('w$')] != 
              \ [mcb_curly_braces.first_lnum, mcb_curly_braces.last_lnum]
          call win_execute(winid, 'call s:detector(self.winnr, self.mandatory)')
        endif
    endfunction
    return l:other_timer
endfunction

function! s:detect_sign(beg, end)
  let signs1 = get(b:, 'mcb_signs', [])
  let signs2 = sign_getplaced(bufnr(), {'group':'*'})[0].signs
  if signs2 != signs1
    for winid in win_findbuf(bufnr()) 
      let winnr = win_id2win(winid)
      if winnr == winnr()
        let b:mcb_detect_sign_val = {'winid':winid,'beg':a:beg,'end':a:end}
      else
        let beg = s:searchpair(winnr, '{', '', '}', 'b')
        let end = s:searchpair(winnr, '{', '', '}', '')
        let b:mcb_detect_sign_val = {'winid':winid,'beg':beg,'end':end}
      endif
      doautocmd User MCB_SignChanged
    endfor
    let b:mcb_signs = signs2
  endif
endfunction

function! s:detect_win_size_change(timer)
  for wininfo in getwininfo()
    let winnr = wininfo.winnr
    if !buflisted(wininfo.bufnr)
      return
    endif
    let size1 = getwinvar(winnr, 'mcb_win_size', [])
    let size2 = [win_screenpos(winnr), winwidth(winnr), winheight(winnr)]
    if size1 != size2
      call setwinvar(winnr, 'mcb_win_size', size2)
      call timer_start(0, s:update_timer.clone(winnr, 1).task, {'repeat': 1})
    endif
  endfor
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

function! s:searchpair_aux(start, middle, end, flags)
  let save_cursor = getcurpos()
  let [lnum, col] = searchpairpos(a:start, a:middle, a:end, 
        \ s:flags(a:flags.'zW'), '', 0, 100)
  while [lnum, col] != [0, 0] 
        \ && synIDattr(synID(lnum, col, 0), 'name') =~ '\vcomment|string'
    let new_cursor = copy(save_cursor)
    let new_cursor[1] = lnum
    let new_cursor[2] = col
    call setpos('.', new_cursor)
    let [lnum, col] = searchpairpos(a:start, a:middle, a:end, 
          \ a:flags.'zW', '', 0, 100)
  endwhile
  call setpos('.', save_cursor)
  let s:searchpair_aux_return = [lnum, col]
endfunction

function! s:searchpair(winnr, start, middle, end, flags)
  call win_execute(win_getid(a:winnr), 
        \ 'call s:searchpair_aux(a:start, a:middle, a:end, a:flags)')
  return s:searchpair_aux_return
endfunction

function! s:detector(winnr, mandatory)
  let [beg_lnum, beg_col] = s:searchpair(a:winnr, '{', '', '}', 'b')
  let [end_lnum, end_col] = s:searchpair(a:winnr, '{', '', '}', '')

  if beg_lnum == 0 || end_lnum == 0 || beg_lnum > end_lnum
    let [beg_lnum, beg_col] = [0, 0]
    let [end_lnum, end_col] = [0, 0]
  endif
  
  let mcb_curly_braces = getwinvar(a:winnr, 'mcb_curly_braces', {})
  let new_mcb_curly_braces = {
        \ 'beg': [beg_lnum, beg_col], 
        \ 'end': [end_lnum, end_col], 
        \ 'first_lnum': line('w0'), 
        \ 'last_lnum': line('w$')
        \ }
  if a:mandatory || mcb_curly_braces != new_mcb_curly_braces
    call setwinvar(a:winnr, 'mcb_curly_braces', new_mcb_curly_braces)
    let g:mcb_curly_braces_winnr = a:winnr
    doautocmd User MCB_CurlyBracesListChanged
  else
    call s:detect_sign([beg_lnum, beg_col], [end_lnum, end_col])
  endif
  return
endfunction

function! s:timer_start_detector()
  for winid in win_findbuf(bufnr()) 
    let winnr = win_id2win(winid)
    call timer_start(20, s:update_timer.clone(winnr, 0).task, {'repeat': 1})
  endfor
endfunction

function! detector#init()
  let s:timer2 = timer_start(100, function('s:detect_win_size_change'), 
        \ { 'repeat': -1 })
  augroup MarkCurlyBracesDetector
    autocmd!
    autocmd CursorMoved,CursorHoldI * call s:timer_start_detector()
  augroup END
endfunction
