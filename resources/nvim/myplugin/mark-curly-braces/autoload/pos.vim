function! pos#get_numberwidth()
  return &number ? max([&numberwidth, strdisplaywidth(line('$'))+1]) : 0
endfunction

function! pos#get_width_of_sign_plus_number()
  let winnr = winnr()
  return screenpos(winnr, line('w0'), 1).col - win_screenpos(winnr)[1]
endfunction

function! pos#get_signwidth()
  return pos#get_width_of_sign_plus_number() - pos#get_numberwidth()
endfunction

function! s:get_wrap_line(lnum)
  if &wrap == v:false 
    return [getline(a:lnum)]
  endif
  let count = 0
  let result = ['']
  "最大显示文本的宽度
  let max_width = winwidth(winnr()) - pos#get_width_of_sign_plus_number()
  for char in split(getline(a:lnum), '\zs')
    let char_width = strdisplaywidth(char)
    if count + char_width > max_width
      call add(result, '')
      let count = 0
    endif
    let result[-1] = result[-1].char
    let count = count + char_width
  endfor
  return result
endfunction

function! pos#get_wrap_line(lnum)
  return s:get_wrap_line(a:lnum)
endfunction


"离上一行(行尾)的距离
function! s:buf_pos2height_from_line(lnum, col)
  let height = 0
  for line in s:get_wrap_line(a:lnum)
    let len = get(l:, 'len', 0) + len(line)
    if a:col <= len
      return height
    endif
    let height = height + 1
  endfor
  return height
endfunction

function! s:buf_pos2height_from_screen(lnum, col)
  if a:lnum < line('w0') || a:lnum > line('w$')
    throw printf("renderer.vim: 无效的[%d, %d]值。", a:lnum, a:col)
  endif
  let winnr = winnr()
  let min_lnum_in_win = line('w0')
  if &wrap == v:true
    return screenpos(winnr, a:lnum, a:col).row
  endif
  return screenpos(winnr,  min_lnum_in_win, 1).row + a:lnum - min_lnum_in_win
endfunction

function! pos#get_screen_line_by_height_from_win(lnum, height)
  if a:lnum == line('w$')+1 "说明lnum行是跨行文本，且一部分没有被显示
    let height = 
          \ s:buf_pos2height_from_screen(a:lnum-1, len(getline(a:lnum-1))) + 1
  else
    let height = s:buf_pos2height_from_screen(a:lnum, 1)
  endif
  "将距离窗口的高度转换为距离屏幕的高度
  let height_from_screen = 
        \ a:height + s:buf_pos2height_from_screen(line('w0'), 1)
  let tmp = s:get_wrap_line(a:lnum)
  if height_from_screen - height < len(tmp)
    return tmp[height_from_screen - height]
  endif
endfunction

function! pos#get_screen_line_by_bufcol(lnum, col)
  return s:get_wrap_line(a:lnum)[s:buf_pos2height_from_line(a:lnum, a:col)]
endfunction


"buffer位置转换为距离窗口的高度,溢出的高度调整为临界值。
"应遵守的约束:
" [beg_lnum, beg_col] <= [line('w$'), 1]
"返回:
" [是否为调整后的高度，高度，buffer行号]
function! pos#beg_buf_pos2height_from_win(beg_lnum, beg_col)
  let min_lnum_in_win = line('w0')
  if a:beg_lnum >= min_lnum_in_win
    let height = s:buf_pos2height_from_screen(a:beg_lnum, a:beg_col)
    let result = [v:false, height, a:beg_lnum]
  else
    let height = s:buf_pos2height_from_screen(min_lnum_in_win, 1)
    let result = [v:true, height, min_lnum_in_win]
  endif
  "距离屏幕高度转换为距离窗口的高度
  let result[1] = result[1] - s:buf_pos2height_from_screen(line('w0'), 1)
  return result
endfunction

"buffer位置转换为距离窗口的高度,溢出的高度调整为临界值。
"应遵守的约束:
" [end_lnum, end_col] >= [line('w0'), 1]
"返回:
" [是否为调整后的高度，高度，buffer行号]
function! pos#end_buf_pos2height_from_win(end_lnum, end_col)
  let max_lnum_in_win = line('w$')
  if a:end_lnum <= max_lnum_in_win
    let height = s:buf_pos2height_from_screen(a:end_lnum, a:end_col)
    let result = [v:false, height, a:end_lnum]
  else
    "窗口所显示的最后一行所在的屏幕高度
    let height1 = win_screenpos(winnr())[0] + winheight(winnr()) - 1
    "窗口所显示的最后一个行号的行(行尾)所在的屏幕高度
    let height2 = s:buf_pos2height_from_screen(
          \  max_lnum_in_win, len(getline(max_lnum_in_win))
          \)
    if height1 != height2 "窗口显示的最后一行是跨行文本
      if a:end_lnum == max_lnum_in_win + 1 "end_lnum行的一部分文本被显示
        "height2+1就是end_lnum行的屏幕高度
        let height = 
              \ height2 + 1 + s:buf_pos2height_from_line(a:end_lnum, a:end_col)
        if height <= height1 "[end_lnum, end_col]在窗口显示了
          let result = [v:false, height, a:end_lnum]
        else
          let result = [v:true, height1, a:end_lnum]
        endif
      else
        let result = [v:true, height1, max_lnum_in_win+1]
      endif
    else
      let result = [v:true, height1, max_lnum_in_win]
    endif
  endif
  "距离屏幕高度转换为距离窗口的高度
  let result[1] = result[1] - s:buf_pos2height_from_screen(line('w0'), 1)
  return result
endfunction

"buffer位置转换为距离窗口的高度,溢出的高度调整为临界值。
"应遵守的约束:
" [beg_lnum, beg_col] >= [end_lnum, end_col]
" [beg_lnum, beg_col] <= [line('w$'), 1]
" [end_lnum, end_col] >= [line('w0'), 1]
"返回:
" beg = [是否为调整后的高度，高度，buffer行号]
" end = [是否为调整后的高度，高度，buffer行号]
" [beg, end]
function! pos#buf_pos2height_from_win(beg_lnum, beg_col, end_lnum, end_col)
  let beg_result = pos#beg_buf_pos2height_from_win(a:beg_lnum, a:beg_col)
  let end_result = pos#end_buf_pos2height_from_win(a:end_lnum, a:end_col)
  return [beg_result, end_result]
endfunction
