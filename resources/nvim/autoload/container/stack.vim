
function! container#stack#init()
    command! -nargs=1 Stack :let <args> = deepcopy(s:stack)
endfunction

let s:stack = { 'data': [], 'idx': 0 }

function! s:stack.empty()
    return empty(self.data)
endfunction

function! s:stack.push(val)
    call add(self.data, a:val)
    let self.idx = self.idx + 1
endfunction

function! s:stack.pop()
    if self.empty()
        throw "Stack.pop:".string(self.data)
    endif
    call remove(self.data, -1)
    let self.idx = self.idx - 1
endfunction

function! s:stack.top()
    if self.empty()
        throw "Stack.top:".string(self.data)
    endif
    return self.data[self.idx-1]
endfunction

function! s:stack.has(val)
    return index(self.data, a:val) != -1 ? v:true : v:false
endfunction
