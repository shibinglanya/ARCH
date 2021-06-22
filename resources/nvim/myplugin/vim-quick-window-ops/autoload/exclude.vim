
function! exclude#exclude(bufnr)
    let l:filetype = getbufvar(a:bufnr, '&filetype')
    for l:item in g:vim_quick_window_ops_exclude
        if l:item == l:filetype
            return v:true
        endif
    endfor
    return v:false
endfunction

