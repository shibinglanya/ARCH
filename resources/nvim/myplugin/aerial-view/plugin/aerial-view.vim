let g:aerial_view_columns = get(g:, 'aerial_view_columns', 15)
let g:aerial_view_enable = get(g:, 'aerial_view_enable', 1)

if g:aerial_view_enable == 1
  call preview#open(
        \ 'SauceCodePro Nerd Font Mono:pixelsize=3', g:aerial_view_columns)
endif

function! s:toggle()
  if preview#active()
    call preview#close()
  else
    call preview#open(
          \ 'SauceCodePro Nerd Font Mono:pixelsize=3', g:aerial_view_columns)
  endif
endfunction

nnoremap <silent><leader>o :call <SID>toggle()<CR>
