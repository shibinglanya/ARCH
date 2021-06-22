" Textprops neovim
" 
" It should be noted that neovim uses zero based indexing like LSP
" this is unlike regular vim APIs which are 1 based.

function! lsp_cxx_hl#textprop_nvim#buf_add_hl_lsrange(buf, ns_id, hl_group,
            \ range) abort
    return s:buf_add_hl(a:buf, a:ns_id, a:hl_group,
                \ a:range['start']['line'],
                \ a:range['start']['character'],
                \ a:range['end']['line'],
                \ a:range['end']['character']
                \ )
endfunction

function! s:buf_add_hl(buf, ns_id, hl_group,
            \ s_line, s_char, e_line, e_char) abort
    " single line symbol
    if a:s_line == a:e_line && a:e_char - a:s_char > 0
        let l:list = getbufline(a:buf, a:s_line+1)
        if empty(l:list)
            return
        endif
        let l:line  = l:list[0]
        let l:start = byteidx(l:line, a:s_char)
        let l:end   = byteidx(l:line, a:e_char)
        if l:start == -1 || l:end == -1 || l:end - l:start <= 0
            return
        else
            call nvim_buf_add_highlight(a:buf, a:ns_id, a:hl_group,
                        \ a:s_line, l:start, l:end)
            return
        endif
    endif
    call lsp_cxx_hl#log('Error (textprop_nvim): symbol spans multiple lines: ',
                \ a:s_line, ' to ', a:e_line)
endfunction

function! lsp_cxx_hl#textprop_nvim#buf_add_hl_skipped_range(buf, ns_id, hl_group,
            \ range) abort

    let l:s_line = a:range['start']['line']
    let l:s_line = l:s_line < 0 ? 0 : l:s_line

    let l:buf_nl = nvim_buf_line_count(a:buf)

    let l:e_line = a:range['end']['line']
    let l:e_line = l:e_line > l:buf_nl - 1 ? l:buf_nl - 1 : l:e_line

    if l:s_line + 1 <= l:e_line - 2
        for l:line in range(l:s_line + 1, l:e_line - 2)
            call nvim_buf_add_highlight(a:buf, a:ns_id, a:hl_group,
                        \ l:line, 0, -1)
        endfor
    endif
endfunction
