execute 'source '. expand('<sfile>:h'). '/../socket.vim'
let s:info = split($SERVERINFO, ',')

if !empty(s:info)
  call aerial_view#socket#init(s:info[0])
  execute printf("SocketExec \"call %s()\"", join(s:info[1:], ','))
endif
