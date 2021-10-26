let g:mcb_log_file = get(g:, 'mcb_log_file', '')

if !empty(g:mcb_log_file)
  if log#init(g:mcb_log_file) == 0
    finish
  endif
endif

"call theme#basic_style2#init()
call detector#init()
call renderer#init()


nnoremap <plug>(mcb-toggle) :call renderer#toggle()<CR>
