execute 'source '. expand('<sfile>:h'). '/socket.vim'
let s:info = split($SERVERINFO, ',')

call socket#init(s:info[0])
execute printf("SocketExec \"call %s()\"", join(s:info[1:], ','))
