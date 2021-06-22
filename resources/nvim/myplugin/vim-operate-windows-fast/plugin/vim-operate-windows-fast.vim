
if exists("g:quick_window_ops_loaded")
    finish
endif

let g:quick_window_ops_loaded = 1

let g:vim_quick_window_ops_exclude = get(g:, 'vim_quick_window_ops_exclude', ['coc-explorer'])

nnoremap <plug>(qwo-move-label-left)    :call tab_action#l_mov(bufnr())<CR>
nnoremap <plug>(qwo-move-label-right)   :call tab_action#r_mov(bufnr())<CR>
nnoremap <plug>(qwo-remove-label-left)  :call tab_action#l_del(bufnr())<CR>
nnoremap <plug>(qwo-remove-label-right) :call tab_action#r_del(bufnr())<CR>


function! s:wrap_action(del_call_back, open_call_back) abort
    if bufname() =~ '\v%(\[Command Line\])'
        return
    endif
    "必须使用winnr()，窗口的编号是动态的（在改变窗口数量下），不是固定分配的。
    if !call(a:del_call_back, [winnr()])
        call call(a:open_call_back, [winnr()])
        return
    endif
    while call(a:del_call_back, [winnr()])
    endwhile
endfunction

nnoremap <plug>(qwo-window-left)  :call <sid>wrap_action('win_action#l_del', 'win_action#l_open')<CR>
nnoremap <plug>(qwo-window-right) :call <sid>wrap_action('win_action#r_del', 'win_action#r_open')<CR>
nnoremap <plug>(qwo-window-up)    :call <sid>wrap_action('win_action#u_del', 'win_action#u_open')<CR>
nnoremap <plug>(qwo-window-down)  :call <sid>wrap_action('win_action#d_del', 'win_action#d_open')<CR>
nnoremap <plug>(qwo-window-close) :call win_action#close(winnr())<CR>


"测试
function! s:MapGenerate(key, plug)
    if exists(a:key) && !empty(eval(a:key))
        execute printf("nmap <silent> %s %s", eval(a:key), a:plug)
    endif
endfunction
call s:MapGenerate('g:OperateWindowsFast_SwitchLeftTab',  '<plug>(qwo-move-label-left)')
call s:MapGenerate('g:OperateWindowsFast_SwitchRightTab', '<plug>(qwo-move-label-right)')
call s:MapGenerate('g:OperateWindowsFast_CloseLeftTab',   '<plug>(qwo-remove-label-left)')
call s:MapGenerate('g:OperateWindowsFast_CloseRightTab',  '<plug>(qwo-remove-label-right)')
call s:MapGenerate('g:OperateWindowsFast_SwitchTab',  '<plug>(qwo-move-label-right)')
call s:MapGenerate('g:OperateWindowsFast_OpenUpWindow',   '<plug>(qwo-window-up)')
call s:MapGenerate('g:OperateWindowsFast_OpenDownWindow', '<plug>(qwo-window-down)')
call s:MapGenerate('g:OperateWindowsFast_OpenLeftWindow', '<plug>(qwo-window-left)')
call s:MapGenerate('g:OperateWindowsFast_OpenRightWindow','<plug>(qwo-window-right)')
call s:MapGenerate('g:OperateWindowsFast_CloseCurrentWindow','<plug>(qwo-window-close)')
