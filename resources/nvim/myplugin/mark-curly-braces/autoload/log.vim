function! s:echo(...)
  autocmd VimEnter * echomsg function('printf', a:000)()
endfunction

function! s:system(...)
  return system(function('printf', a:000)())
endfunction

let s:dir =  expand("<sfile>:p:h")
function! log#init(echo_file)
  let dir_name_list = split(s:dir, '\V/')
  if len(dir_name_list) < 2
    call s:echo('log.vim: 路径 %s 不能解析！', s:dir)
    return -1
  endif
  if dir_name_list[-1] != 'autoload'
    call s:echo('log.vim: log.vim文件不在autoload目录下。')
    return -1
  endif

  let dir = '/tmp/'. dir_name_list[-2]. getpid()
  if filewritable(dir) == 2
    return 1
  endif
  call s:system('mkdir "%s"', dir)
  call s:system('cp -rf "%s/../" "%s"', s:dir, dir)

  execute printf("autocmd VimLeavePre * call s:system('rm -rf \"%s\"')", dir)

  for file in split(s:system('find "%s" -type f -name "*.vim"', dir))
    let lines = s:write_debug_info(readfile(file), a:echo_file)
    call writefile(lines, file)
  endfor

  "保证修改后的脚本代码优先被选择
  execute printf('let &rtp = "%s,". &rtp', dir)
  execute printf('autocmd VimEnter * let &rtp = "%s,". &rtp', dir)

  for file in split(s:system('find "%s/plugin" -type f -name "*.vim"', dir))
    execute 'source '. file
  endfor
  return 0
endfunction

function! s:write_debug_info(lines, echo_file)
  let ret_lines = [printf('let s:echo_file = "%s"', a:echo_file)]
  let ret_lines = ret_lines + ['function! s:log_write(...) abort']
  let ret_lines = ret_lines + ["call writefile([strftime('[%H:%M:%S]: '). function('printf', a:000)()], s:echo_file, 'a')"]
  let ret_lines = ret_lines + ['endfunction']
  for line in a:lines
    if line =~ '\v^"""\s'
      let ret_lines = ret_lines + 
            \ [printf('call s:log_write(%s)', line[3:])]
      continue
    endif
    let ret_lines = ret_lines + [line]
  endfor
  return ret_lines
endfunction
