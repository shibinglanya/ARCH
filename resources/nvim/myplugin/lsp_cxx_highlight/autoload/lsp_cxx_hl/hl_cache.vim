function! s:get_symbols(bufnr) abort
    return getbufvar(a:bufnr, 'lsp_symbols', [])
endfunction

function! s:update_symbols(bufnr, symbols) abort
    call setbufvar(a:bufnr, 'lsp_symbols', a:symbols)
endfunction

function! s:get_start_end(winnr) abort
    let start = getwinvar(a:winnr, 'lsp_start', -1)
    let end   = getwinvar(a:winnr, 'lsp_end', -1)
    return [start, end]
endfunction

function! s:set_start_end(winnr, start, end) abort
    call setwinvar(a:winnr, 'lsp_start', a:start)
    call setwinvar(a:winnr, 'lsp_end', a:end)
endfunction

function! s:update_start_end(winnr, lines, threshold_value) abort
    "如果已经高亮，直接返回。
    let start = a:lines[1] - a:threshold_value*2/3
    let end   = a:lines[1] + a:threshold_value*2/3
    let start = start < a:lines[0] ? a:lines[0] : start
    let end   = end   > a:lines[2] ? a:lines[2] : end 
    for wininfo in getwininfo()
        if wininfo.bufnr == winbufnr(a:winnr)
            let [start2, end2] = s:get_start_end(wininfo.winnr)
            if start2 == -1 || end2 == -1
                break
            elseif start2 <= start && end <= end2
                return v:false
            endif
        endif
    endfor

    "未在高亮范围，重新计算高亮范围。
    let start = a:lines[1] - a:threshold_value
    let start = start >= a:lines[0] ? start : a:lines[0]
    let end   = a:threshold_value*2 + start
    let start = end > a:lines[2] ? start - (end - a:lines[2]) : start

    call setwinvar(a:winnr, 'lsp_start', start)
    call setwinvar(a:winnr, 'lsp_end', end)
    return v:true
endfunction
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"过滤除了光标所在行号的上下阀值`threshold_value`范围内的语法高亮，
"以提升语法高亮效率。
function! s:filter_symbols(symbols, start, end) abort
    for val in a:symbols
        call filter(val.lsRanges, 
                \ "v:val.end.line <= a:end && v:val.start.line >= a:start")
    endfor
    return filter(a:symbols, '!empty(v:val.lsRanges)')
endfunction

function! s:filter_symbols_not(symbols, start, end) abort
    for val in a:symbols
        call filter(val.lsRanges, 
                \ "v:val.end.line > a:end || v:val.start.line < a:start")
    endfor
    return filter(a:symbols, '!empty(v:val.lsRanges)')
endfunction

function! lsp_cxx_hl#hl_cache#symbols(bufnr, symbols) abort
    if !g:lsp_cxx_hl_cache_enabled
        return a:symbols
    elseif !bufexists(a:bufnr)
        return []
    elseif !empty(a:symbols)
        call s:update_symbols(a:bufnr, a:symbols)
    endif

    let result_symbols = []
    for wininfo in getwininfo()
        if wininfo.bufnr == a:bufnr
            let [start, end] = s:get_start_end(wininfo.winnr)
            call extend(result_symbols, s:filter_symbols(
                    \ deepcopy(s:get_symbols(wininfo.bufnr)), start, end))
        endif
    endfor

    return uniq(sort(result_symbols))
endfunction

let s:hl_timer = {  }
function! s:hl_timer.clone(winnr, lines, threshold_value) abort
    call setwinvar(a:winnr, 'lsp_id', getwinvar(a:winnr, 'lsp_id', -1) + 1)
    let other_timer                 = copy(self)
    let other_timer.id              = getwinvar(a:winnr, 'lsp_id', -1)
    let other_timer.winnr           = a:winnr
    let other_timer.lines           = a:lines
    let other_timer.threshold_value = a:threshold_value
    function! l:other_timer.task(timer) abort
        if self.id != getwinvar(self.winnr, 'lsp_id', -1)
            return
        elseif !s:update_start_end(self.winnr, self.lines, self.threshold_value)
            return
        elseif empty(s:get_symbols(winbufnr(self.winnr)))
            return
        endif

        call lsp_cxx_hl#notify_symbols('ccls', winbufnr(self.winnr), [])

        let g:lsp_cxx_hl_cache_enabled = 0
        call lsp_cxx_hl#notify_symbols('ccls', winbufnr(self.winnr), 
                    \ s:get_symbols(winbufnr(self.winnr)))
    endfunction
    return l:other_timer
endfunction

function! lsp_cxx_hl#hl_cache#hl(winnr) abort
    if !g:lsp_cxx_hl_cache_enabled
        return
    endif
    call timer_start(g:lsp_cxx_hl_cache_cursor_update_time, 
                \ s:hl_timer.clone(a:winnr, [1, line('.'), line('$')], 
                    \ g:lsp_cxx_hl_cache_threshold_value).task, 
                \ {'repeat': 1})
endfunction

let s:update_timer = {  }
function! s:update_timer.clone(winnr) abort
    call setwinvar(a:winnr, 'lsp_update_id', 
                \ getwinvar(a:winnr, 'lsp_update_id', -1) + 1)
    let l:other_timer                 = copy(self)
    let l:other_timer.id              = getwinvar(a:winnr, 'lsp_update_id', -1)
    let l:other_timer.winnr           = a:winnr
    function! l:other_timer.task(timer) abort
        if self.id == getwinvar(self.winnr, 'lsp_update_id', -1)
            call coc#rpc#notify('CocAutocmd', 
                        \ ['BufWritePost', +winbufnr(self.winnr)])
        endif
    endfunction
    return l:other_timer
endfunction

function! lsp_cxx_hl#hl_cache#update(winnr) abort
    call s:update_symbols(bufnr(a:winnr), [])
    call timer_start(g:lsp_cxx_hl_update_time, 
                \ s:update_timer.clone(a:winnr).task, 
                \ {'repeat': 1})
endfunction
