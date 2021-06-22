let s:PairsParser = { "left":{}, "right":{} }
function! s:PairsParser.init(string)
    let list1 = split(a:string.',', '[^,],')
    let list2 = split(','.a:string, ',[^,]')
    for idx in range(len(list1))
        let self.left[list1[idx]] = list2[idx]
        let self.right[list2[idx]] = list1[idx]
    endfor
endfunction
function! s:PairsParser.lhas(char)
    return has_key(self.left, a:char)
endfunction
function! s:PairsParser.rhas(char)
    return has_key(self.right, a:char)
endfunction
function! s:PairsParser.linquire(key)
    return self.left[a:key]
endfunction
function! s:PairsParser.rinquire(key)
    return self.right[a:key]
endfunction
command! -nargs=1 PairsParser :let <args> = deepcopy(s:PairsParser)

if !exists('g:FastCursorMovement_Words')
    let g:FastCursorMovement_Words = '\w,[:],[.]'
endif
if !exists('g:FastCursorMovement_Pairs')
    let g:FastCursorMovement_Pairs = "{},(),[],<>,\"\",''"
endif

call container#bufiostream#init()
call container#stack#init()

function! s:FastCursorMovementForward(words, pairs, iostream) abort
    PairsParser parser
    call parser.init(a:pairs)
    let regex1 = printf('\v(%s)', join(split(a:words, ','), '|'))
    if a:iostream.peek() =~ regex1
        while !a:iostream.empty()
            \ && a:iostream.peek() =~ regex1
            call a:iostream.ignore()
        endwhile
    elseif parser.lhas(a:iostream.peek())
        let save_iostream = copy(a:iostream)
        Stack stack
        call stack.push(a:iostream.get())
        while !a:iostream.empty() && !stack.empty()
            let curchar = a:iostream.get()
            if curchar == "\n" && a:iostream.peek() == "\n"
                call a:iostream.rignore()
                break
            elseif stack.top() == '"' && curchar == '\'
                call a:iostream.ignore()
            elseif stack.top() == "'" && curchar == "'"
                \ && a:iostream.peek() == "'"
                call a:iostream.ignore()
            elseif (stack.top() == '"' && curchar != '"')
                \ || (stack.top() == "'" && curchar != "'")
            elseif parser.rhas(curchar) && stack.has(parser.rinquire(curchar))
                while stack.top() != parser.rinquire(curchar)
                    call stack.pop()
                endwhile
                call stack.pop()
            elseif parser.lhas(curchar)
                call stack.push(curchar)
            endif
        endwhile
        if !stack.empty()
            let a:iostream.idx = save_iostream.idx
            let a:iostream.lnum = save_iostream.lnum
            call a:iostream.ignore()
        endif
    else
        call a:iostream.ignore()
    endif
endfunction

function! s:FastCursorMovementBackward(words, pairs, iostream) abort
    PairsParser parser
    call parser.init(a:pairs)
    let regex1 = printf('\v(%s)', join(split(a:words, ','), '|'))
    if a:iostream.rpeek() =~ regex1
        while !a:iostream.rempty()
            \ && a:iostream.rpeek() =~ regex1
            call a:iostream.rignore()
        endwhile
    elseif parser.rhas(a:iostream.rpeek())
        let save_iostream = copy(a:iostream)
        Stack stack
        call stack.push(a:iostream.rget())
        while !a:iostream.rempty() && !stack.empty()
            let curchar = a:iostream.rget()
            if curchar == "\n" && a:iostream.rpeek() == "\n"
                call a:iostream.ignore()
                break
            elseif stack.top() == '"' && curchar == '"'
                \ && a:iostream.rpeek() == '\'
                call a:iostream.rignore()
            elseif stack.top() == "'" && curchar == "'"
                \ && a:iostream.rpeek() == "'"
                call a:iostream.rignore()
            elseif (stack.top() == '"' && curchar != '"')
                \ || (stack.top() == "'" && curchar != "'")
            elseif parser.lhas(curchar) && stack.has(parser.linquire(curchar))
                while stack.top() != parser.linquire(curchar)
                    call stack.pop()
                endwhile
                call stack.pop()
            elseif parser.rhas(curchar)
                call stack.push(curchar)
            endif
        endwhile
        if !stack.empty()
            let a:iostream.idx = save_iostream.idx
            let a:iostream.lnum = save_iostream.lnum
            call a:iostream.rignore()
        endif
    else
        call a:iostream.rignore()
    endif
    call a:iostream.flush()
endfunction



function! s:RightCharacterForward(words, pairs) abort
    let backup = @"
    BufIOStream iostream
    call iostream.init()
    let char = iostream.peek()
    call iostream.remove()
    call s:FastCursorMovementForward(a:words, a:pairs, iostream)
    call iostream.put(char)
    call iostream.flush()
    let @" = backup
    return ""
endfunction

function! s:RightCharacterBackward(words, pairs) abort
    let backup = @"
    BufIOStream iostream
    call iostream.init()
    let char = iostream.peek()
    call iostream.remove()
    call s:FastCursorMovementBackward(a:words, a:pairs, iostream)
    call iostream.put(char)
    call iostream.flush()
    let @" = backup
    return ""
endfunction

function! s:RightCharacterToTail(words, pairs) abort
    let backup = @"
    BufIOStream iostream
    for x in range(20)
        call s:RightCharacterForward(a:words, a:pairs)
        call iostream.init()
        call iostream.ignore()
        if iostream.peek() == "\n"
            break
        endif
    endfor
    let @" = backup
    return ""
endfunction

function! s:LeftCharacterForward(words, pairs) abort
    let backup = @"
    BufIOStream iostream
    call iostream.init()
    let char = iostream.rpeek()
    call iostream.rremove()
    call s:FastCursorMovementForward(a:words, a:pairs, iostream)
    call iostream.rput(char)
    call iostream.flush()
    let @" = backup
    return ""
endfunction

function! s:LeftCharacterBackward(words, pairs) abort
    let backup = @"
    BufIOStream iostream
    call iostream.init()
    let char = iostream.rpeek()
    call iostream.rremove()
    call s:FastCursorMovementBackward(a:words, a:pairs, iostream)
    call iostream.rput(char)
    call iostream.flush()
    let @" = backup
    return ""
endfunction

function! s:LeftCharacterToTail(words, pairs) abort
    let backup = @"
    BufIOStream iostream
    for x in range(20)
        call s:LeftCharacterForward(a:words, a:pairs)
        call iostream.init()
        if iostream.peek() == "\n"
            break
        endif
    endfor
    let @" = backup
    return ""
endfunction

function! s:CursorForward(words, pairs) abort
    BufIOStream iostream
    call iostream.init()
    call s:FastCursorMovementForward(a:words, a:pairs, iostream)
    call iostream.flush()
    return ""
endfunction

function! s:CursorBackward(words, pairs) abort
    BufIOStream iostream
    call iostream.init()
    call s:FastCursorMovementBackward(a:words, a:pairs, iostream)
    call iostream.flush()
    return ""
endfunction

function! s:CursorToTail(words, pairs) abort
    BufIOStream iostream
    for x in range(20)
        call s:CursorForward(a:words, a:pairs)
        call iostream.init()
        if iostream.peek() == "\n"
            break
        endif
    endfor
    return ""
endfunction

function! s:DeleteBackward(words, pairs) abort
    let backup = @"
    BufIOStream pos1
    BufIOStream pos2
    call pos1.init()
    call pos2.init()
    call s:FastCursorMovementBackward(a:words, a:pairs, pos2)
    while pos2.lnum != pos1.lnum
        \ || pos2.idx != pos1.idx
        call pos1.rremove()
    endwhile
    call pos1.flush()
    let @" = backup
    return ""
endfunction

function! s:MapGenerate(key, func, words, pairs)
    if exists(a:key) && !empty(eval(a:key))
        execute printf("inoremap <silent> %s <C-R>=<SID>%s(%s, %s)<CR>",
                    \ eval(a:key), a:func, a:words, a:pairs)
    endif
endfunction
call s:MapGenerate('g:FastCursorMovement_LeftCharacter_Forward', 
            \ 'LeftCharacterForward'  , 'g:FastCursorMovement_Words', 'g:FastCursorMovement_Pairs')
call s:MapGenerate('g:FastCursorMovement_RightCharacter_Forward', 
            \ 'RightCharacterForward' , 'g:FastCursorMovement_Words', 'g:FastCursorMovement_Pairs')
call s:MapGenerate('g:FastCursorMovement_LeftCharacter_Backward', 
            \ 'LeftCharacterBackward' , 'g:FastCursorMovement_Words', 'g:FastCursorMovement_Pairs')
call s:MapGenerate('g:FastCursorMovement_RightCharacter_Backward', 
            \ 'RightCharacterBackward', 'g:FastCursorMovement_Words', 'g:FastCursorMovement_Pairs')
call s:MapGenerate('g:FastCursorMovement_LeftCharacter_Tail', 
            \ 'LeftCharacterToTail'   , 'g:FastCursorMovement_Words', 'g:FastCursorMovement_Pairs')
call s:MapGenerate('g:FastCursorMovement_RightCharacter_Tail', 
            \ 'RightCharacterToTail'  , 'g:FastCursorMovement_Words', 'g:FastCursorMovement_Pairs')
call s:MapGenerate('g:FastCursorMovement_Forward', 
            \ 'CursorForward'         , 'g:FastCursorMovement_Words', 'g:FastCursorMovement_Pairs')
call s:MapGenerate('g:FastCursorMovement_Backward', 
            \ 'CursorBackward'        , 'g:FastCursorMovement_Words', 'g:FastCursorMovement_Pairs')
call s:MapGenerate('g:FastCursorMovement_Tail', 
            \ 'CursorToTail'        , 'g:FastCursorMovement_Words', 'g:FastCursorMovement_Pairs')
call s:MapGenerate('g:FastCursorMovement_DeleteBackward', 
            \ 'DeleteBackward'        , 'g:FastCursorMovement_Words', 'g:FastCursorMovement_Pairs')
