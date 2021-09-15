if get(g:, 'mcb_debug_disabled', 0)
  let echo_file = '/tmp/mcb_debug.log'
  "call debug#display('detector.vim', 's:searchpair')
  execute debug#enter(expand('<sfile>'), expand('<slnum>') + 1, echo_file)
endif

let s:update_timer = {  }
function! s:update_timer.clone(winnr) abort
    call setwinvar(a:winnr, 'mcb_detector_update_id', 
                \ getwinvar(a:winnr, 'mcb_detector_update_id', -1) + 1)
    let l:other_timer       = copy(self)
    let l:other_timer.id    = getwinvar(a:winnr, 'mcb_detector_update_id', -1)
    let l:other_timer.winnr = a:winnr
    function! l:other_timer.task(timer) abort
        if self.id == getwinvar(self.winnr, 'mcb_detector_update_id', -1)
          call s:detector(winnr())
        endif
    endfunction
    return l:other_timer
endfunction

function! s:detect_sign(timer)
  let signs1 = get(b:, 'mcb_signals', [])
  let signs2 = sign_getplaced(bufnr(), {'group':'*'})[0].signs
  if signs2 != signs1
    let b:mcb_signals = signs2
    doautocmd User MCB_SignChanged
  endif
endfunction

function! s:detect_win_size_change(timer)
  for wininfo in getwininfo()
    let winnr = wininfo.winnr
    if empty(bufname(wininfo.bufnr)) | return | endif
    let size1 = getwinvar(winnr, 'mcb_win_size', [])
    let size2 = [win_screenpos(winnr), winwidth(winnr), winheight(winnr)]
    if size1 != size2
      call setwinvar(winnr, 'mcb_win_size', size2)
      call s:detector(winnr)
    endif
  endfor
endfunction

function! detector#init()
  let s:timer1 = timer_start(100, function('s:detect_sign'), { 'repeat': -1 })
  let s:timer2 = timer_start(100, function('s:detect_win_size_change'), 
        \ { 'repeat': -1 })
  
  augroup MarkCurlyBracesDetector
    autocmd!
    autocmd CursorMoved,CursorMovedI * 
      \ call timer_start(60, s:update_timer.clone(winnr()).task, {'repeat': 1})
    autocmd BufEnter * call s:detector(winnr())
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
  let s:searchpair_aux_return = lnum
endfunction

function! s:searchpair(winnr, start, middle, end, flags)
  let winid = filter(getwininfo(), 'v:val.winnr == a:winnr')[0].winid
  call win_execute(winid, 
        \ 'call s:searchpair_aux(a:start, a:middle, a:end, a:flags)')
  return s:searchpair_aux_return
endfunction

function! s:detector(winnr)
  let beg_lnum = s:searchpair(a:winnr, '{', '', '}', 'b')
  let end_lnum = s:searchpair(a:winnr, '{', '', '}', '')

  if beg_lnum == 0 || end_lnum == 0 || beg_lnum > end_lnum
    let beg_lnum = 0
    let end_lnum = 0
  endif
  
  let g:mcb_curly_braces = [a:winnr, beg_lnum, end_lnum]
  doautocmd User MCB_CurlyBracesListChanged
  return
endfunction

