function! s:TabAction(move, action) abort
    let bufinfo = getbufinfo()
    let list = filter(range(len(bufinfo)), 'bufinfo[v:val].listed == 1')
    let length = len(list)
    for idx in list
        if bufinfo[idx].bufnr == bufnr('%')
            if a:move == "left"
                let idx = index(list, idx) - 1
            elseif a:move == "right"
                let idx = index(list, idx) + 1
            elseif a:move == "loop"
                let idx = (index(list, idx) + 1)%length
            endif
            break
        endif
    endfor
    if idx != length && idx != -1
        if a:action == "del"
            silent! execute 'bw'. bufinfo[list[idx]].bufnr 
        elseif a:action == "mov"
            silent! execute 'b'. bufinfo[list[idx]].bufnr 
        endif
    endif
endfunction

function! s:DeleteExistingWindows(move)
    let list = filter(getwininfo(), 'buflisted(v:val.bufnr)')
    let xy = win_screenpos(winnr())
    for other_win in filter(list, 'v:val.winnr != winnr()')
        if a:move == "left"
            \ && xy[0] == win_screenpos(other_win.winnr)[0]
            \ && xy[1] > win_screenpos(other_win.winnr)[1]
            silent! execute other_win.winnr ."close"
            return 1
        elseif a:move == "right"
            \ && xy[0] == win_screenpos(other_win.winnr)[0]
            \ && xy[1] < win_screenpos(other_win.winnr)[1]
            silent! execute other_win.winnr ."close"
            return 1
        elseif a:move == "up"
            \ && xy[1] == win_screenpos(other_win.winnr)[1]
            \ && xy[0] > win_screenpos(other_win.winnr)[0]
            silent! execute other_win.winnr ."close"
            return 1
        elseif a:move == "down"
            \ && xy[1] == win_screenpos(other_win.winnr)[1]
            \ && xy[0] < win_screenpos(other_win.winnr)[0]
            silent! execute other_win.winnr ."close"
            return 1
        endif
    endfor
    return 0
endfunction

function! s:WindowAction(move) abort
    let ret = s:DeleteExistingWindows(a:move)
    while s:DeleteExistingWindows(a:move)
    endwhile
    if !ret && a:move == "left"
        silent! execute "to vsp"
        normal! zz
    elseif !ret && a:move == "right"
        silent! execute "bo vsp"
        normal! zz
    elseif !ret && a:move == "up"
        silent! execute "to sp"
        normal! zz
    elseif !ret && a:move == "down"
        silent! execute "bo sp"
        normal! zz
    endif
endfunction

function! s:Close() abort
    let winlist = filter(getwininfo(), 'bufname(v:val.bufnr) !=""')
    let buflist = filter(getbufinfo(), 'v:val.listed == 1')
    if len(winlist) > 1
        silent! execute "close" 
        return
    endif
    if getbufinfo(bufnr())[0].changed
        silent! execute "w"
        return
    endif
    if len(buflist) > 1
        silent! execute "bw%"
        return
    endif
    silent! execute "q"
endfunction


function! s:MapGenerate(key, func)
    if exists(a:key) && !empty(eval(a:key))
        execute printf("nnoremap <silent> %s :call <SID>%s<CR>",
                    \ eval(a:key), a:func)
    endif
endfunction
call s:MapGenerate('g:QuickOperationWindow_LeftMoveLabel',  'TabAction("left",  "mov")')
call s:MapGenerate('g:QuickOperationWindow_RightMoveLabel', 'TabAction("right", "mov")')
call s:MapGenerate('g:QuickOperationWindow_LeftDelLabel',   'TabAction("left",  "del")')
call s:MapGenerate('g:QuickOperationWindow_RightDelLabel',  'TabAction("right", "del")')
call s:MapGenerate('g:QuickOperationWindow_LoopMoveLabel',  'TabAction("loop",  "mov")')
call s:MapGenerate('g:QuickOperationWindow_UpOpenWindow',   'WindowAction("up")')
call s:MapGenerate('g:QuickOperationWindow_DownOpenWindow', 'WindowAction("down")')
call s:MapGenerate('g:QuickOperationWindow_LeftOpenWindow', 'WindowAction("left")')
call s:MapGenerate('g:QuickOperationWindow_RightOpenWindow','WindowAction("right")')
call s:MapGenerate('g:QuickOperationWindow_CloseCurrentWindow','Close()')
