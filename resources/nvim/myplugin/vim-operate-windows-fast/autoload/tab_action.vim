function! s:buf_do(bufinfo, bufnr, call_back)
    if exclude#exclude(a:bufnr)
        return
    endif

    for l:bufinfo in filter(a:bufinfo, '!empty(bufname(v:val.bufnr))')
        if l:bufinfo.bufnr == a:bufnr
            let l:finish = v:true
        elseif get(l:, 'finish', v:false)
            "不在标签内的直接删除掉。
            if !buflisted(l:bufinfo.bufnr)
                silent! execute 'bwipeout '.l:bufinfo.bufnr
                continue
            endif
            unlet l:finish
            call call(a:call_back, [l:bufinfo.bufnr])
            return v:true
        endif
    endfor
    return v:false
endfunction

function! tab_action#r_del(bufnr) abort
    call s:buf_do(getbufinfo(), a:bufnr, 
                \ {nr->execute('bwipeout '.nr, 'silent!')})
endfunction

function! tab_action#r_mov(bufnr) abort
    call s:buf_do(getbufinfo(), a:bufnr, 
                \ {nr->execute('buffer '.nr, 'silent!')})
endfunction

function! tab_action#l_del(bufnr) abort
    call s:buf_do(reverse(getbufinfo()), a:bufnr, 
                \ {nr->execute('bwipeout '.nr, 'silent!')})
endfunction

function! tab_action#l_mov(bufnr) abort
    call s:buf_do(reverse(getbufinfo()), a:bufnr, 
                \ {nr->execute('buffer '.nr, 'silent!')})
endfunction
