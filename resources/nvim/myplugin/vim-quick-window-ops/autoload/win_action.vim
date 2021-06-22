function! s:win_del(winnr, condition) abort
    for l:wininfo in filter(getwininfo(), 'v:val.winnr != a:winnr')
        let l:xy = win_screenpos(l:wininfo.winnr)
        if call(a:condition, [l:xy[0], l:xy[1]])
            silent! execute l:wininfo.winnr .'close'
            return v:true
        endif
    endfor
    return v:false
endfunction

function! win_action#l_del(winnr) abort
    let l:xy = win_screenpos(a:winnr)
    return s:win_del(a:winnr, {x, y->l:xy[0] == x && l:xy[1] > y})
endfunction

function! win_action#r_del(winnr) abort
    let l:xy = win_screenpos(a:winnr)
    return s:win_del(a:winnr, {x, y->l:xy[0] == x && l:xy[1] < y})
endfunction

function! win_action#u_del(winnr) abort
    let l:xy = win_screenpos(a:winnr)
    return s:win_del(a:winnr, {x, y->l:xy[0] > x && l:xy[1] == y})
endfunction

function! win_action#d_del(winnr) abort
    if exclude#exclude(winbufnr(a:winnr))
        return
    endif

    let l:xy = win_screenpos(a:winnr)
    return s:win_del(a:winnr, {x, y->l:xy[0] < x && l:xy[1] == y})
endfunction

function! win_action#l_open(winnr) abort
    if exclude#exclude(winbufnr(a:winnr))
        return
    endif

    silent! execute "topleft vsplit"
    normal! zz
endfunction

function! win_action#r_open(winnr) abort
    if exclude#exclude(winbufnr(a:winnr))
        return
    endif

    silent! execute "botright vsplit"
    normal! zz
endfunction

function! win_action#u_open(winnr) abort
    if exclude#exclude(winbufnr(a:winnr))
        return
    endif

    silent! execute "topleft split"
    normal! zz
endfunction

function! win_action#d_open(winnr) abort
    if exclude#exclude(winbufnr(a:winnr))
        return
    endif

    silent! execute "botright split"
    normal! zz
endfunction

function! win_action#close(winnr) abort
    if expand('%') ==# '[Command Line]'
        call execute(printf("normal! \<CR>"))
    elseif len(filter(getwininfo(), '!empty(bufname(v:val.bufnr))')) > 1
        silent! execute a:winnr. 'close' 
    elseif getbufvar(winbufnr(a:winnr), '&modified')
        silent! execute winbufnr(a:winnr). 'bufdo! write'
    elseif len(filter(getbufinfo(), 'buflisted(v:val.bufnr)')) > 1
        silent! execute 'bwipeout'. winbufnr(a:winnr)
    else
        silent! execute 'quit'
    endif
endfunction
