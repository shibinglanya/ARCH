function! plug_extension#init(sfile, slnum)
  let tmpfilename = '/tmp/vim_plug_config_'. getftime(a:sfile). '.vim'
  if !filereadable(tmpfilename)
    call s:generate_config_file(a:sfile, a:slnum, tmpfilename)
  endif
  execute 'source '.tmpfilename
  return 'finish'
endfunction

" execute plug_extension#init(expand('<sfile>'), expand('<slnum>'))
" **1**
" call plug#begin('~/.config/nvim/plugged') **2**
" Plug XXXX **2** {
"   **4**
" }
" call plug#end() **2**
" **3**

function s:generate_config_file(sfile, slnum, path)
  let lines = readfile(a:sfile)[a:slnum:]
  let lines_written1 = []
  let lines_written2 = []
  let lines_written3 = []
  let lines_written4 = []
  let n = 1
  for line in lines
    let r = matchlist(line, '\v^(Plug .{-})%(\{\s*)?$'.
          \ '|^(call\s+plug#begin\(.+)$'.
          \ '|^(call\s+plug#end\(.+)$|^\}\s*$')
    if !empty(r)
      if !empty(r[1]) "Plug XXXX
        call add(lines_written2, r[1])
      elseif !empty(r[2]) "call plug#begin
        let n = 4
        call add(lines_written2, r[2])
      elseif !empty(r[3]) "call plug#end
        let n = 3
        call add(lines_written2, r[3])
      endif
    else
      call add(lines_written{n}, line)
    endif
  endfor
  let lines_written = []
  let lines_written = extend(lines_written, lines_written1)
  let lines_written = extend(lines_written, lines_written2)
  let lines_written = extend(lines_written, lines_written3)
  let lines_written = extend(lines_written, lines_written4)
  call writefile(lines_written, a:path)
endfunction
