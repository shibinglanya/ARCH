execute 'source '. expand('<sfile>:h'). '/socket.vim'
let s:info = split($SERVERINFO, ',')
command! -nargs=+ SocketExec :call socket#command(s:info[0], <f-args>)
execute printf("SocketExec \"call %s()\"", join(s:info[1:], ','))
