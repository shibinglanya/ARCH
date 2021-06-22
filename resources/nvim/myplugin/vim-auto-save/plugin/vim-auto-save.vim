if exists("g:auto_save_loaded")
    finish
endif

"init.vim -> plugin
let g:auto_save                   = get(g:, 'auto_save', 1)
let g:auto_save_whitelist         = get(g:, 'auto_save_whitelist', ['*'])
let g:auto_save_events            = get(g:, 'auto_save_events', ['InsertLeave', 'TextChanged'])
let g:auto_save_delay             = get(g:, 'auto_save_delay', 0)
let g:auto_save_event_delay       = get(g:, 'auto_save_event_delay', 0.3)
let g:auto_save_presave_hook      = get(g:, 'auto_save_presave_hook', '')
let g:auto_save_postsave_hook     = get(g:, 'auto_save_postsave_hook', '')
let g:auto_save_silent            = get(g:, 'auto_save_silent', 0)
let g:auto_save_write_all_buffers = get(g:, 'auto_save_write_all_buffers', 1)

function! s:hl_echo_escape(msg, is_om)
    if a:is_om == v:true
        let l:msg = substitute(a:msg, '\v\\\[', '[', 'g')
        let l:msg = substitute(l:msg, '\v\\\]', ']', 'g')
        let l:msg = substitute(l:msg, '\v\\\:', ':', 'g')
        return l:msg
    else
        let l:msg = substitute(a:msg, '\v\[', '\\[', 'g')
        let l:msg = substitute(l:msg, '\v\]', '\\]', 'g')
        let l:msg = substitute(l:msg, '\v\:', '\\:', 'g')
        return l:msg
    endif
endfunction

highlight def AutoSaveRun ctermfg=green
highlight def AutoSaveEnable ctermfg=green
highlight def AutoSaveDisable ctermfg=red

function! s:hl_echo(hl_msg)
    let l:split_reg = '\v%(\\)@<!%(\[)@=|%(\])@<=%(\\])@<!'
    for l:split_msg in split(a:hl_msg, l:split_reg)
        if l:split_msg =~ '\v^\[.+\]$'
            let [l:msg, l:group] = split(l:split_msg, '\v%(\\)@<!\[|\]%(\\])@<!|%(\\)@<!:')
            let l:msg = s:hl_echo_escape(l:msg, v:true)
            execute 'echohl '. l:group
            echon l:msg
            echohl NONE
        else
            let l:msg = s:hl_echo_escape(l:split_msg, v:true)
            echohl Normal
            echon l:msg
            echohl NONE
        endif
    endfor
endfunction


function! s:init() abort
    " Check all used events exist
    let l:auto_save_events = copy(g:auto_save_events)
    for l:idx in range(len(l:auto_save_events))
        let l:event = l:auto_save_events[l:idx]
        if !exists("##" . l:event)
            call remove(g:auto_save_events, l:idx)
            call s:hl_echo('[\[AutoSave\]:ErrorMsg] [let g\:auto_save_events = '. s:hl_echo_escape(string(l:auto_save_events), v:false). ":ErrorMsg]\n".
                        \"[\\[AutoSave\\]:ErrorMsg] Save on [" . s:hl_echo_escape(l:event, v:false) . ":Underlined] event is not supported for your Vim version!\n".
                        \"[\\[AutoSave\\]:ErrorMsg] [" . s:hl_echo_escape(l:event, v:false) . ":Underlined] was removed from g:auto_save_events variable.\n".
                        \"[\\[AutoSave\\]:ErrorMsg] Please, upgrade your Vim to a newer version or use other events in [g\\:auto_save_events:Underlined]!")
        endif
    endfor

    let s:timer = {  }
    function! s:timer.clone() abort
        let s:id             = get(s:, 'id', -1) + 1
        let l:other_timer    = copy(self)
        let l:other_timer.id = s:id
        function! l:other_timer.task(timer) abort
            if self.id == s:id
                call s:auto_save(g:auto_save)
            endif
        endfunction
        return l:other_timer
    endfunction


    augroup auto_save
        autocmd!
        for l:event in g:auto_save_events 
            execute printf('autocmd %s %s nested call timer_start(%d, s:timer.clone().task, {"repeat": 1})', 
                        \ l:event, join(g:auto_save_whitelist, ','), float2nr(g:auto_save_event_delay*1000))
        endfor
    augroup END

    if g:auto_save_delay > 0 && !exists('s:delay_timer')
        let s:delay_timer = timer_start(float2nr(g:auto_save_delay*1000), 
                    \ {->s:auto_save(g:auto_save)}, {'repeat': -1})
    endif
endfunction "s:init()
autocmd VimEnter * call timer_start(500, {->s:init()}, {'repeat': 1})

function s:auto_save(enabled) abort
    if !a:enabled
        return
    endif

    let was_modified = s:is_modified()
    if !was_modified
        return
    endif

    if !empty("g:auto_save_presave_hook")
        let g:auto_save_abort = 0
        execute g:auto_save_presave_hook
        if g:auto_save_abort >= 1
            return
        endif
    endif

    call s:do_save(bufnr())

    if was_modified && !&modified
        if !empty("g:auto_save_postsave_hook")
            execute g:auto_save_postsave_hook
        endif
        if g:auto_save_silent == 0
            call s:hl_echo("[\\[AutoSave\\]:AutoSaveRun] saved at " . s:hl_echo_escape(strftime("%H:%M:%S")))
        endif
    endif
endfunction

function s:is_modified() abort
    if !g:auto_save_write_all_buffers
        return &modified
    endif
    return len(filter(getbufinfo(), 
                \ 'getbufvar(v:val.bufnr, "&modified")')) > 0
endfunction

function! s:do_save_single_file(bufnr) abort
    if a:bufnr != bufnr()
        let l:save_a_mark = getpos('.')
        execute printf('silent! %dbufdo w|b#', a:bufnr)
        call setpos('.', l:save_a_mark)
    else
        silent! w
    endif
endfunction

function s:do_save(bufnr) abort
    if !g:auto_save_write_all_buffers
        call s:do_save_single_file(a:bufnr)
        return
    endif

    for l:bufnr in map(getbufinfo(), 'v:val.bufnr')
        for l:elem in g:auto_save_whitelist
            if bufname(l:bufnr) =~ glob2regpat(l:elem) && 
                        \ getbufvar(l:bufnr, "&modified")
                call s:do_save_single_file(l:bufnr)
            endif
        endfor
    endfor
endfunction

function s:auto_save_enable() abort
    call s:hl_echo("[\\[AutoSave\\]:AutoSaveRun] [ON:AutoSaveEnable]")
    if !g:auto_save
        let g:auto_save = 1
        call s:init()
    endif
endfunction

function s:auto_save_disable() abort
    call s:hl_echo("[\\[AutoSave\\]:AutoSaveRun] [OFF:AutoSaveDisable]")
    if !g:auto_save
        return
    endif
    let g:auto_save = 0
    augroup auto_save
        autocmd!
    augroup END

    if g:auto_save_delay > 0 && exists('s:delay_timer')
        call timer_stop(s:delay_timer)
        unlet s:delay_timer
    endif
endfunction

function s:auto_save_toggle() abort
    if g:auto_save
       call s:auto_save_disable()
    else
       call s:auto_save_enable()
    endif
endfunction

command! -nargs=0 AutoSave        :call s:auto_save(1)
command! -nargs=0 AutoSaveEnable  :call s:auto_save_enable()
command! -nargs=0 AutoSaveDisable :call s:auto_save_disable()
command! -nargs=0 AutoSaveToggle  :call s:auto_save_toggle()
