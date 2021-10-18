""" '---------------BEGIN---------------'
let g:aerial_view_columns = get(g:, 'aerial_view_columns', 15)
let g:aerial_view_enable = get(g:, 'aerial_view_enable', 1)
let g:aerial_view_log_file = get(g:, 'aerial_view_log_file', '')

if !empty(g:aerial_view_log_file)
  if log#init(g:aerial_view_log_file) == 0
    finish
  endif
endif

if g:aerial_view_enable == 1
  call aerial_view#preview#open('self',
        \ 'SauceCodePro Nerd Font Mono:pixelsize=3', g:aerial_view_columns)
endif

function! s:toggle()
  if aerial_view#preview#active()
    call aerial_view#preview#close('self')
  else
    call aerial_view#preview#open('self',
          \ 'SauceCodePro Nerd Font Mono:pixelsize=3', g:aerial_view_columns)
  endif
endfunction

nnoremap <silent><leader>o :call <SID>toggle()<CR>
