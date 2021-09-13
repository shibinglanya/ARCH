
function! debug#enter(sfile, slnum, echo_file)
  let s:echo_file = a:echo_file
  let file_name = split(a:sfile, '\V/')[-1]
  let tmp_file_path = '/tmp/'. file_name
  if filereadable(tmp_file_path)
    call delete(tmp_file_path)
  endif
  let lines = readfile(a:sfile)[a:slnum:]
  let lines = s:write_debug_info(file_name, lines)
  call writefile(lines, tmp_file_path)
  execute 'source '.tmp_file_path
  return 'finish'
endfunction

function! s:add(pair, to_buf_list_name) "pair = [script_id, script_name]
  let list = get(b:, a:to_buf_list_name, [])
  if index(list, a:pair) == -1
    call add(list, a:pair)
    call setbufvar(bufnr(), a:to_buf_list_name, list)
  endif
endfunction

function! s:find(buf_list_name, pair)
  for val in get(b:, a:buf_list_name, [])
    if val == a:pair
      return v:true
    endif
  endfor
  return v:false
endfunction

function! debug#filter(script, func)
  if type(a:script) == v:t_string "script_name
    let script_id = s:name2id(a:script)
  elseif type(a:script) == v:t_number "script_id
    let script_id = a:script
  else
    return
  endif
  call s:add([script_id, a:func], 'debug_filter_list') 
endfunction

function! debug#display(script, func)
  if type(a:script) == v:t_string "script_name
    let script_id = s:name2id(a:script)
  elseif type(a:script) == v:t_number "script_id
    let script_id = a:script
  else
    return
  endif
  call s:add([script_id, a:func], 'debug_display_list') 
endfunction

func! s:writefile(...) abort
  if !empty(trim(s:echo_file))
    call writefile([strftime("[%H:%M:%S]:"). join(a:000, ' ')], 
          \ s:echo_file, 'a')
  endif
endf

function! debug#func_begin(script_file_name, 
      \ fun_name, fun_lnum, fun_par, fun_arg) abort
  return { 
          \'reltime':          reltime(),
          \'script_file_name': a:script_file_name,
          \'fun_name':         a:fun_name,
          \'fun_lnum':         a:fun_lnum,
          \'fun_par':          a:fun_par,
          \'fun_arg':          a:fun_arg,
        \}
endfunction


function! s:name2id(name)
  let debug_name2id_list = get(b:, 'debug_name2id_list', [])
  let id = index(debug_name2id_list, a:name)
  if id == -1
    call add(debug_name2id_list, a:name)
    call setbufvar(bufnr(), 'debug_name2id_list', debug_name2id_list)
    return len(debug_name2id_list)
  endif
  return id+1
endfunction

function! s:id2name(id)
  let debug_name2id_list = get(b:, 'debug_name2id_list', [])
  if a:id-1 < len(debug_name2id_list)
    return debug_name2id_list[a:id-1]
  endif
  return ''
endfunction

function! debug#func_end(info, return) abort
  let reltime          = a:info.reltime
  let script_file_name = a:info.script_file_name
  let fun_name         = a:info.fun_name
  let fun_lnum         = a:info.fun_lnum
  let fun_arg          = a:info.fun_arg
  let fun_par          = a:info.fun_par

  let script_id = s:name2id(script_file_name)
  if !empty(get(b:, 'debug_display_list', []))
    if !s:find('debug_display_list', [script_id, fun_lnum])
          \ && !s:find('debug_display_list', [script_id, fun_name])
      return
    endif
  elseif s:find('debug_filter_list', [script_id, fun_lnum])
        \ || s:find('debug_filter_list', [script_id, fun_name])
    return
  endif

  call s:writefile('')
  call s:writefile(printf('{(%d)%s:%s}: %s(%s)', s:name2id(script_file_name),
        \ script_file_name, fun_lnum, fun_name, join(fun_par, ', ')))
  if fun_arg != fun_par
    for idx in range(len(fun_arg))
      let arg = fun_arg[idx]
      let par = fun_par[idx]

      if type(arg) == v:t_string
        call s:writefile(printf("{arg%d} %s: '%s'", idx, par, arg))
      else
        call s:writefile(printf('{arg%d} %s: %s', idx, par, arg))
      endif
    endfor
  endif
  call s:writefile(printf('return: %s', a:return))
  call s:writefile(printf('time(ms):%s', trim(reltimestr(reltime(reltime)))))
  call s:writefile('')
endfunction

function! s:write_debug_info(filename, lines)
  "function! #1(#2)
  let fbeg_regex = '\v^\s*func%(tion){-}!?\s+([^\(]+)\(([^)]*)\)\s*%(abort){-}$'
  "return #1
  let fret_regex = '\v^\s*return(\s+.*){-}\s*$'
  "endfunction
  let fend_regex = '\v^\s*endf%(unction){-}\s*$'

  let lines = s:process_lines(a:lines)
  let result = []
  for idx in range(len(lines))
    let cur_line = lines[idx]
    call add(result, cur_line)

    "function! #1(#2)
    let fbeg_match_result = matchlist(cur_line, fbeg_regex)
    if !empty(fbeg_match_result)
      if empty(trim(fbeg_match_result[2])) "function! #1()
        let debug_info = printf(
          \ "let debug_beg = debug#func_begin('%s', '%s', %d, ['void'], ['void'])"
          \ , a:filename, fbeg_match_result[1], idx+1
        \)
        call add(result, debug_info)
      else "function! #1(#2)
        let tmp = split(fbeg_match_result[2], '\V,')
        " a:arg1, a:arg2
        let argument_list = join(map(copy(tmp), '"a:". trim(v:val)'), ',')
        " 'arg1', 'arg2'
        let parameter_list = join(map(copy(tmp), '"\"".trim(v:val)."\""'), ',')
        let debug_info = printf(
          \ "let debug_beg = debug#func_begin('%s', '%s', %d, [%s], [%s])"
          \ , a:filename, fbeg_match_result[1], idx+1
          \ , parameter_list, argument_list
        \)
        call add(result, debug_info)
      endif
      continue
    endif

    "return #1
    let fret_match_result = matchlist(cur_line, fret_regex)
    if !empty(fret_match_result)
      if empty(trim(fret_match_result[1])) "return
        let debug_info = printf('call debug#func_end(debug_beg, "void")')
        call insert(result, debug_info, -1)
      else "return #1
        let debug_info = printf(
          \ 'call debug#func_end(debug_beg, %s)'
          \ , trim(fret_match_result[1])
        \)
        call insert(result, debug_info, -1)
      endif
      continue
    endif

    "endfunction
    let fend_match_result = matchlist(cur_line, fend_regex)
    if !empty(fend_match_result)
      call insert(result, 'call debug#func_end(debug_beg, "void")', -1)
      continue
    endif
  endfor

  return result
endfunction

"处理出现于行首的反斜杠
function! s:process_lines(lines)
  return a:lines
endfunction


