
"pacman -S python-pip
"pip3 install pynvim
"pip3 install nest_asyncio

function! socket#command(path, ...)
  let command = eval('printf('.join(a:000).')')
python3 << EOF
import nest_asyncio
from pynvim import attach
nest_asyncio.apply()
nvim = attach('socket', path=vim.eval('a:path'))
nvim.command(vim.eval('l:command'))
EOF
endfunction
