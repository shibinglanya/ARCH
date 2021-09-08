

func theme#basic_style5#init()
	hi def IndentLineSign ctermfg=8 cterm=bold
		autocmd User SelfSignChanged call s:self_sign_changed()
		autocmd User OtherSignHidden call s:other_sign_hidden()
endf

function! s:self_sign_changed()
	call renderer#place(' │', 'IndentLineSign')
endfunction

func s:other_sign_hidden()
	call renderer#place(' '. trim(b:sd_sign_defined.text), b:sd_sign_defined.texthl)
endfunction
