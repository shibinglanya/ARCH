function! s:update_line() abort
    if g:lsp_cxx_hl_cache_enabled
        let l:start = line('.') - winline()
        let l:end   = l:start + winheight(winnr())
        call setwinvar(winnr(), 'lsp_cxx_start', l:start - 50)
        call setwinvar(winnr(), 'lsp_cxx_end', l:end + 50)
    endif
endfunction

function! s:get_start_end(winnr) abort
    let start = getwinvar(a:winnr, 'lsp_cxx_start', -1)
    let end   = getwinvar(a:winnr, 'lsp_cxx_end', -1)
    return [start, end]
endfunction

function! lsp_cxx_hl_cache#init()
    if !g:lsp_cxx_hl_cache_enabled
        return
    endif
    augroup lsp_cxx_hl_cache
        autocmd!
        autocmd CursorMoved,CursorMovedI * call s:update_line()
        autocmd TextChanged,TextChangedI,TextChangedP,BufEnter * 
                        \ call lsp_cxx_hl_cache#update(bufnr())
    augroup END
endfunction

function! s:filter_symbols(is_ccls, symbols, start, end) abort
    if a:is_ccls
        let tmp = deepcopy(a:symbols)
        for val in tmp
            call filter(val.lsRanges, 
                    \ "v:val.end.line <= a:end && v:val.start.line >= a:start")
        endfor
        return filter(tmp, '!empty(v:val.lsRanges)')
    endif
endfunction

function! lsp_cxx_hl_cache#notify_symbols(is_ccls, bufnr, symbols) abort
    if !g:lsp_cxx_hl_cache_enabled
        return lsp_cxx_hl#notify_symbols_aux(a:is_ccls, a:bufnr, a:symbols)
    endif

    call timer_stop(getbufvar(a:bufnr, 'lsp_cxx_cache_timer', 0))
    call setbufvar(a:bufnr, 'lsp_cxx_cache_update_count', 
                \ getbufvar(a:bufnr, 'lsp_cxx_cache_update_count', 0) - 1)
    if getbufvar(a:bufnr, 'lsp_cxx_cache_update_count', 0) <= 0
        call setbufvar(a:bufnr, 'lsp_cxx_cache_update_count', 0)
        let l:timer = timer_start(2000,
                \ {->lsp_cxx_hl#notify_symbols_aux(a:is_ccls, a:bufnr, a:symbols)},
                \ {'repeat': 1})
        call setbufvar(a:bufnr, 'lsp_cxx_cache_timer', l:timer)
    else
        return
    endif

    let symbols_tmp = []
    for wininfo in getwininfo()
        if wininfo.bufnr == a:bufnr
            let [start, end] = s:get_start_end(wininfo.winnr)
            call extend(symbols_tmp, s:filter_symbols(a:is_ccls,
                    \ a:symbols, start, end))
        endif
    endfor

    call lsp_cxx_hl#notify_symbols_aux(a:is_ccls, a:bufnr, symbols_tmp)
endfunction

let s:update_timer = {  }
function! s:update_timer.clone(bufnr) abort
    call setbufvar(a:bufnr, 'lsp_update_id', 
                \ getbufvar(a:bufnr, 'lsp_update_id', 0) + 1)
    let l:other_timer       = copy(self)
    let l:other_timer.id    = getbufvar(a:bufnr, 'lsp_update_id', 0)
    let l:other_timer.bufnr = a:bufnr
    function! l:other_timer.task(timer) abort
        if self.id == getbufvar(self.bufnr, 'lsp_update_id', 0)
            call setbufvar(self.bufnr, 'lsp_cxx_cache_update_count', 
                    \ getbufvar(self.bufnr, 'lsp_cxx_cache_update_count', 0) + 1)
            call coc#rpc#notify('CocAutocmd', ['BufWritePost', +self.bufnr])
        endif
    endfunction
    return l:other_timer
endfunction

function! lsp_cxx_hl_cache#update(bufnr) abort
    call timer_start(g:lsp_cxx_hl_update_time, 
                \ s:update_timer.clone(a:bufnr).task, 
                \ {'repeat': 1})
endfunction
