let s:iostream = { 'lnum':0, 'idx':0 }

function! container#bufiostream#init()
    command! -nargs=1 BufIOStream let <args> = deepcopy(s:iostream)
endfunction

function! s:iostream.init()
    let self.lnum = line('.')
    let line = getline(self.lnum)
    for self.idx in range(strchars(line)+1)
        if byteidxcomp(line, self.idx) == col('.')-1
            return
        endif
    endfor
endfunction

function! s:iostream.empty()
    if self.lnum == line('$')
        \ && self.idx == strchars(getline(self.lnum))
        return v:true
    endif
    return v:false
endfunction

function! s:iostream.flush()
    call cursor(self.lnum, byteidxcomp(getline(self.lnum), self.idx)+1)
endfunction

function! s:iostream.get()
    if self.idx == strchars(getline(self.lnum))
        if self.lnum != line('$') 
            let self.lnum = self.lnum + 1
            let self.idx = 0
        endif
        return "\n"
    endif
    let self.idx = self.idx + 1
    return strcharpart(getline(self.lnum), self.idx-1, 1)
endfunction

function! s:iostream.ignore()
    if self.idx == strchars(getline(self.lnum))
        if self.lnum != line('$') 
            let self.lnum = self.lnum + 1
            let self.idx = 0
        endif
        return
    endif
    let self.idx = self.idx + 1
endfunction

function! s:iostream.peek()
    if self.idx == strchars(getline(self.lnum))
        return "\n"
    endif
    return strcharpart(getline(self.lnum), self.idx, 1)
endfunction

function! s:iostream.remove()
    if self.idx == strchars(getline(self.lnum))
        if self.lnum != line('$') 
            let line = getline(self.lnum)
            let line .= getline(self.lnum+1)
            call setline(self.lnum, line)
            call deletebufline('%', self.lnum+1)
        endif
        return
    endif
    let chars = split(getline(self.lnum), '\zs')
    call remove(chars, self.idx)
    call setline(self.lnum, join(chars, ''))
endfunction

function! s:iostream.put(val)
    let chars = split(getline(self.lnum), '\zs')
    if a:val != "\n"
        call insert(chars, a:val, self.idx)
        call setline(self.lnum, join(chars, ''))
    else
        if self.idx == 0
            call setline(self.lnum, "")
        else
            call setline(self.lnum, join(chars[0:self.idx-1], ''))
        endif
        call setline(self.lnum+1, join(chars[self.idx:-1], ''))
    endif
endfunction

function! s:iostream.rempty()
    if self.lnum == 1 && self.idx == 0
        return v:true
    endif
    return v:false
endfunction

function! s:iostream.rget()
    if self.idx == 0
        if self.lnum != 1
            let self.lnum = self.lnum - 1
            let self.idx = strchars(getline(self.lnum))
        endif
        return "\n"
    endif
    let self.idx = self.idx - 1
    return strcharpart(getline(self.lnum), self.idx, 1)
endfunction

function! s:iostream.rignore()
    if self.idx == 0
        if self.lnum != 1
            let self.lnum = self.lnum - 1
            let self.idx = strchars(getline(self.lnum))
        endif
        return
    endif
    let self.idx = self.idx - 1
endfunction

function! s:iostream.rpeek()
    if self.idx == 0
        return "\n"
    endif
    return strcharpart(getline(self.lnum), self.idx-1, 1)
endfunction

function! s:iostream.rremove()
    if self.idx == 0
        if self.lnum != 1 
            let self.idx = strchars(getline(self.lnum-1))
            let self.lnum = self.lnum - 1
            let line = getline(self.lnum)
            let line .= getline(self.lnum+1)
            call setline(self.lnum, line)
            call deletebufline('%', self.lnum+1)
        endif
        return
    endif
    let chars = split(getline(self.lnum), '\zs')
    let self.idx = self.idx - 1
    call remove(chars, self.idx)
    call setline(self.lnum, join(chars, ''))
endfunction

function! s:iostream.rput(val)
    call self.put(a:val)
    let self.idx = self.idx + 1
endfunction
