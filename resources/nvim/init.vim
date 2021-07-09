let mapleader = "\<space>"

"添加配对的字符
set mps+=<:>
"NVIM内部使用的字符编码方式
set encoding=utf-8
"文件保存编码
set fileencoding=utf-8
"TAB宽度
set shiftwidth=2
"设置制表符为4的倍数"
set softtabstop=2
"文件里的 <Tab> 代表的空格数
set tabstop=2
"插入模式里: 插入 <Tab> 时使用合适数量的空格
set expandtab
"打开， ’>’ 和 ’<’ 命令使用空格进行缩进
set autoindent
"高亮指定列
set colorcolumn=80
"启用行编号
set number
"高亮光标所在行
set cursorline
"翻页上下间隙行数
set scrolloff=5
"智能搜索忽略大小写
set ignorecase smartcase
"屏蔽ins-completion-menu消息
set shortmess+=c
"使用命令`%s//`显示替换效果
set inccommand=nosplit
"VIM响应时间
set updatetime=100
"允许在有未保存的修改时切换缓冲区
set hidden
"自动切换目录
set autochdir
"以+寄存器作为默认寄存器
set clipboard=unnamedplus
"设置备份目录
silent !mkdir -p ~/.cache/nvim/tmp/backup
silent !mkdir -p ~/.cache/nvim/tmp/undo
set backupdir=~/.cache/nvim/tmp/backup,.
set directory=~/.cache/nvim/tmp/backup,.
if has('persistent_undo')
	set undofile
	set undodir=~/.cache/nvim/tmp/undo,.
endif

"引导插件配置
let BootstrapPlugConfig = {}

"let g:plug_url_format = "https://git::@github.com.cnpmjs.org/%s.git"
let g:plug_url_format = "https://git::@ghproxy.com/https://github.com/%s.git"

call plug#begin('~/.config/nvim/plugged')

"VIM主题 
"╭────────────────────────────────────────────────────────────────────────────╮
Plug '~/.config/nvim/myplugin/vim-hybrid'
function! BootstrapPlugConfig.Hybrid()
	colorscheme hybrid
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"状态栏 
"╭────────────────────────────────────────────────────────────────────────────╮
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
function! BootstrapPlugConfig.DeployAirline()
	"允许在有未保存的修改时切换缓冲区
	set hidden
	let g:airline_filetype_overrides = {
				\	'coc-explorer': ['coc-explorer', ''],
				\	'vim-plug':     ['Plugins', ''],
				\}
	"启用标签箭头
	let g:airline_powerline_fonts                   = 1
	"主题
	let g:airline_theme                             = 'dark'
	"显示缓存编号
	let g:airline#extensions#tabline#buffer_nr_show = 1
	"显示顶部状态栏
	let g:airline#extensions#tabline#enabled        = 1
	"标签只显示文件名字，不显示路径
	let g:airline#extensions#tabline#formatter      = 'short_path'

	let g:airline_section_b = '%R' "显示是否只读
	let g:airline_section_c = '%<%F' "显示文件路径
	let g:airline_section_z = '%l/%L-%p%%'

	if !exists('g:airline_symbols')
		let g:airline_symbols = {}
	endif
	let g:airline_left_sep          = ''
	let g:airline_left_alt_sep      = ''
	let g:airline_right_sep         = ''
	let g:airline_right_alt_sep     = ''
	let g:airline_symbols.branch    = ''
	let g:airline_symbols.colnr     = ''
	let g:airline_symbols.readonly  = ''
	let g:airline_symbols.linenr    = '☰'
	let g:airline_symbols.maxlinenr = ''
	let g:airline_symbols.dirty     = '⚡'
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"快速光标跳转
"╭────────────────────────────────────────────────────────────────────────────╮
Plug 'easymotion/vim-easymotion'
Plug 'haya14busa/incsearch.vim'
Plug 'haya14busa/incsearch-fuzzy.vim'
Plug 'haya14busa/incsearch-easymotion.vim'
function! BootstrapPlugConfig.DeployIncsearch()
	"禁用默认映射
	let g:EasyMotion_do_mapping = 0
	"不区分大小写
	let g:EasyMotion_smartcase  = 1

	nmap <leader><leader> <Plug>(easymotion-overwin-f)

	function! s:config_easyfuzzymotion(...) abort
		return extend(copy({
					\'converters': [incsearch#config#fuzzyword#converter()],
					\'modules':    [incsearch#config#easymotion#module({'overwin': 1})],
					\'keymap':     {"\<CR>": '<Over>(easymotion)'},
					\'is_expr':    0,
					\'is_stay':    1
					\}), get(a:, 1, {}))
	endfunction
	noremap <silent><expr> g/ incsearch#go(<SID>config_easyfuzzymotion())
	noremap <silent> <leader>/ :let &hls = (&hls + 1)%2<CR>
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"快速窗口操作
"╭────────────────────────────────────────────────────────────────────────────╮
Plug '~/.config/nvim/myplugin/vim-operate-windows-fast'
function! BootstrapPlugConfig.DeployOperateWindowsFast()
	"把lens项目移到这个项目中了，并做了一些bug修复。
	"Plug 'camspiers/lens.vim'
	let g:lens#height_resize_max = 30
	let g:lens#height_resize_min = 20
	let g:lens#width_resize_max  = 130
	let g:lens#width_resize_min  = 30

	nnoremap <silent> <c-h> <C-W>h
	nnoremap <silent> <c-j> <C-W>j
	nnoremap <silent> <c-k> <C-W>k
	nnoremap <silent> <c-l> <C-W>l

	let g:OperateWindowsFast_SwitchTab          = '<TAB>'
	let g:OperateWindowsFast_CloseLeftTab       = '<C-s>'
	let g:OperateWindowsFast_CloseRightTab      = '<C-w>'
	let g:OperateWindowsFast_SwitchLeftTab      = '<C-q>'
	let g:OperateWindowsFast_SwitchRightTab     = '<C-e>'
	let g:OperateWindowsFast_OpenLeftWindow     = '<C-n><C-h>'
	let g:OperateWindowsFast_OpenDownWindow     = '<C-n><C-j>'
	let g:OperateWindowsFast_OpenUpWindow       = '<C-n><C-k>'
	let g:OperateWindowsFast_OpenRightWindow    = '<C-n><C-l>'
	let g:OperateWindowsFast_CloseCurrentWindow = '<C-n><C-m>'
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"快速括号操作
"╭────────────────────────────────────────────────────────────────────────────╮
"快速选择文本
Plug 'gcmt/wildfire.vim'
"快速删除、添加成对的符号
Plug 'tpope/vim-surround'
"为vim-easyclip、vim-surround提供重复操作
Plug 'tpope/vim-repeat'
function! BootstrapPlugConfig.DeploySurround()
	let g:surround_no_insert_mappings = 1
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"复制
"╭────────────────────────────────────────────────────────────────────────────╮
Plug 'svermeulen/vim-easyclip'
function! BootstrapPlugConfig.EasyClip()
	let g:EasyClipAutoFormat             = 0 "粘贴后，自动调整缩进。
	let g:EasyClipUseCutDefaults         = 0
	let g:EasyClipUsePasteToggleDefaults = 0
	let g:EasyClipUseSubstituteDefaults  = 0
	nmap s  <Plug>MoveMotionPlug
	xmap s  <Plug>MoveMotionXPlug
	nmap ss <Plug>MoveMotionLinePlug
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"自动键入成对的括号
"╭────────────────────────────────────────────────────────────────────────────╮
Plug 'jiangmiao/auto-pairs'
function! BootstrapPlugConfig.DeployAutoPairs()
	let g:AutoPairsMultilineClose   = 0
	let g:AutoPairsShortcutFastWrap = 0
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"给括号添加颜色
"╭────────────────────────────────────────────────────────────────────────────╮
Plug 'luochen1990/rainbow'
function! BootstrapPlugConfig.DeployRainbow()
	let g:rainbow_active = 1
  let ctermfgs = [2, 165, 1, 214]
  let parentheses = [
        \ 'start=/\v(( |\<)@<!\<|\<( |\<)@!)((\s|\S|\n){-}( )@<!\>( )@!)@=/ end=/>/ fold',
        \ 'start=/(/ end=/)/ fold', 
        \ 'start=/\[/ end=/\]/ fold', 
        \ 'start=/{/ end=/}/ fold'
        \]
  let g:rainbow_conf = {
        \ 'cterms': ['bold'],
        \ 'ctermfgs': ctermfgs,
        \ 'operators': '_,_',
        \ 'parentheses': parentheses
        \}
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"单词标记颜色
"╭────────────────────────────────────────────────────────────────────────────╮
Plug 'lfv89/vim-interestingwords' 
function! BootstrapPlugConfig.DeployInterestingWords()
	let g:interestingWordsDefaultMappings = 0
	nnoremap <silent> <leader>k :call InterestingWords('n')<cr>
	vnoremap <silent> <leader>k :call InterestingWords('v')<cr>
	nnoremap <silent> <leader>K :call UncolorAllWords()<cr>
	nnoremap <silent>     n     :call WordNavigation(1)<cr>
	nnoremap <silent>     N     :call WordNavigation(0)<cr>
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"快速文本对齐
"╭────────────────────────────────────────────────────────────────────────────╮
Plug 'junegunn/vim-easy-align'
function! BootstrapPlugConfig.DeployEasyAlign()
	"ex:
	"	 = Around the 1st occurrences
	"	2= Around the 2nd occurrences
	"	*= Around all occurrences
	"	-= Around the last occurrences

	"Start interactive EasyAlign in visual mode (e.g. vipga)
	xmap <S-Tab> <Plug>(EasyAlign)

	" Start interactive EasyAlign for a motion/text object (e.g. gaip)
	"nmap ga <Plug>(EasyAlign)
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"文件自动存储
"╭────────────────────────────────────────────────────────────────────────────╮
Plug '~/.config/nvim/myplugin/vim-auto-save'
function! BootstrapPlugConfig.DeployAutoSave()
	let g:auto_save           = 1
	let g:auto_save_delay     = -1
	let g:auto_save_events    = ['FocusLost']
	let g:auto_save_silent    = 1
	let g:auto_save_whitelist = ['*.c', '*.cpp', '*.hpp']
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"COC
"╭────────────────────────────────────────────────────────────────────────────╮
Plug 'neoclide/coc.nvim', {'branch': 'release'}
function! BootstrapPlugConfig.DeployCoc()
	set updatetime=50
	set signcolumn=yes

	nmap <silent>           -     <Plug>(coc-diagnostic-prev)
	nmap <silent>           =     <Plug>(coc-diagnostic-next)
	nmap <silent>          gd     <Plug>(coc-definition)
	nmap <silent>          gi     <Plug>(coc-implementation)
	nmap <silent>          gr     <Plug>(coc-references)
	nmap <silent>          gt     <Plug>(coc-type-definition)
	nmap <silent>       <leader>n <Plug>(coc-rename)
	nmap <silent>       <leader>a :<C-u>CocList diagnostics<cr>
	imap <silent><expr> <c-n> coc#refresh()
	nmap <silent>           K     :call <SID>show_documentation()<CR>

	function! s:show_documentation()
		if (index(['vim','help'], &filetype) >= 0)
			execute 'h '.expand('<cword>')
		else
			call CocAction('doHover')
		endif
	endfunction

	nnoremap <silent> <leader>y :<C-u>CocList -A --normal yank<cr>

	let g:coc_global_extensions = [
				\'coc-json', 'coc-vimlsp', 'coc-yank', 'coc-git',]
				"\'coc-rainbow-fart']

	autocmd VimEnter * hi GitGutterAdd                 cterm=none ctermfg	=	46
	autocmd VimEnter * hi GitGutterChange              cterm=none ctermfg	=	226
	autocmd VimEnter * hi GitGutterDelete              cterm=none ctermfg	=	15

	autocmd VimEnter * hi CocErrorSign                 cterm=bold ctermfg	=	9
	autocmd VimEnter * hi CocWarningSign               cterm=bold ctermfg	=	130
	autocmd VimEnter * hi CocErrorFloat                cterm=none ctermfg	=	9
	autocmd VimEnter * hi CocWarningFloat              cterm=none ctermfg	=	130
	autocmd VimEnter * hi CocErrorVirtualText          cterm=none ctermfg	=	9
	autocmd VimEnter * hi CocWarningVirtualText        cterm=none ctermfg	=	130
	autocmd VimEnter * hi CocExplorerDiagnosticError   cterm=none ctermfg	=	9
	autocmd VimEnter * hi CocExplorerDiagnosticWarning cterm=none ctermfg	=	130

	autocmd CursorHold * silent call CocActionAsync('highlight')
	autocmd VimEnter * hi CocHighlightText cterm = italic,bold,underline
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"C++文件高亮
"╭────────────────────────────────────────────────────────────────────────────╮
Plug '~/.config/nvim/myplugin/lsp_cxx_highlight', { 'for': [ 'c', 'cpp' ] }
function! BootstrapPlugConfig.DeployLspCxxHighlight()
	autocmd BufRead,BufNewFile *.h set filetype=c
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"缩进线
"╭────────────────────────────────────────────────────────────────────────────╮
Plug 'yggdroot/indentline'
function! BootstrapPlugConfig.DeployIndentline()
	let g:indentLine_bufNameExclude = ['_.*', '.*\.json']
  "let g:indentLine_char_list = ['│', '|', '¦', '┆', '┊']
  let g:indentLine_char_list = ['┊']
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯


"自定义按键配置basic
"╭────────────────────────────────────────────────────────────────────────────╮
function! BootstrapPlugConfig.DeployCustomConfig()
	inoremap <expr> <CR>  pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
	inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<right>"
	inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<left>"
	inoremap				<C-g> <Del>
	"inoremap <silent> <C-l> <C-R>=<SID>cursor_to_ending()<CR>
	inoremap <silent><expr> <C-l> pumvisible() ? "\<C-y>\<Esc>$a" : "\<Esc>$a"
	"function! s:cursor_to_ending()
	"    call container#bufiostream#init()
	"    BufIOStream iostream
	"    call iostream.init()
	"    while !iostream.empty() && iostream.peek() != "\n"
	"        call iostream.ignore()
	"    endwhile
	"    while !iostream.rempty() && iostream.rpeek() == ' '
	"        call iostream.rignore()
	"    endwhile
	"    call iostream.flush()
	"    return ""
	"endfunction

	cnoremap <expr> <C-J> pumvisible() ? "\<C-N>" : "\<C-J>"
	cnoremap <expr> <C-K> pumvisible() ? "\<C-P>" : "\<C-K>"
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"
"╭────────────────────────────────────────────────────────────────────────────╮
Plug '~/.config/nvim/myplugin/FastCursorMovement.vim'
function! BootstrapPlugConfig.DeployFCM()
	let g:FastCursorMovement_Pairs                   = "{},(),[],<>,\"\",''"
	let g:FastCursorMovement_Words                   = '\w,[:],[.]'

	let g:FastCursorMovement_Backward                = '<C-D>'
	let g:FastCursorMovement_LeftCharacter_Forward   = '<C-e>'
	let g:FastCursorMovement_Forward                 = '<C-F>'
	let g:FastCursorMovement_LeftCharacter_Backward  = '<C-q>'
	let g:FastCursorMovement_DeleteBackward          = '<C-s>'
	let g:FastCursorMovement_LeftCharacter_Tail      = '<C-w>'
	let g:FastCursorMovement_RightCharacter_Forward  = '<A-e>'
	let g:FastCursorMovement_RightCharacter_Backward = '<A-q>'
	let g:FastCursorMovement_RightCharacter_Tail     = '<A-w>'
	let g:FastCursorMovement_Tail                    = ''
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"FZF
"╭────────────────────────────────────────────────────────────────────────────╮
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
function! BootstrapPlugConfig.DeployFZF()
	set rtp+=/usr/local/opt/fzf
	set rtp+=~/.fzf
	let g:fzf_preview_window = ['right:50%', 'ctrl-/']

	nnoremap <silent> <leader>F :GFiles?<CR>
	command! -bang -nargs=? -complete=dir GFiles
			\ call fzf#vim#gitfiles('?', {'options': [
			\			'--bind=ctrl-l:preview-page-down,ctrl-h:preview-page-up', 
			\			'--preview-window=60%'
			\]}, <bang>0)

	nnoremap <silent> <leader>b :Buffers<CR>
	nnoremap <silent> <leader>f :Files ~<CR>
	nnoremap <silent> <leader>z :Ag<CR>
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"翻译
"╭────────────────────────────────────────────────────────────────────────────╮
Plug 'voldikss/vim-translator'
function! BootstrapPlugConfig.DeployTranslator()
	let g:translator_default_engines    = ['bing', 'google', 'haici', 'youdao']
	let g:translator_history_enable     = v:true
	let g:translator_proxy_url          = ''
	let g:translator_source_lang        = 'auto'
	let g:translator_target_lang        = 'zh'
	let g:translator_window_borderchars = ['─','│','─','│','╭','╮','╯','╰']
	let g:translator_window_type        = 'popup'
	let g:translator_window_max_width   = 0.6
	let g:translator_window_max_height  = 0.6

	hi def link Translator       Normal
	hi def link TranslatorBorder Normal

	nmap <silent> <Leader>r <Plug>TranslateR
	vmap <silent> <Leader>r <Plug>TranslateRV
	nmap <silent> <Leader>t <Plug>Translate
	vmap <silent> <Leader>t <Plug>TranslateV
	nmap <silent> <Leader>w <Plug>TranslateW
	vmap <silent> <Leader>w <Plug>TranslateWV
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯



"ex: w suda:///etc/hosts
Plug 'lambdalisue/suda.vim'



"插件存在bug，以后再处理吧。
"Plug '~/.config/nvim/myplugin/vim-hlchunk'

"Plug 'iamcco/mathjax-support-for-mkdp'


"╭────────────────────────────────────────────────────────────────────────────╮
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npm i'  }
function! BootstrapPlugConfig.DeployMarkdownPreview()
	let g:mkdp_auto_start = 1
	let g:mkdp_browser = 'surf'
  let g:mkdp_theme = 'light' "可能会在后续跟新这个功能
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"╭────────────────────────────────────────────────────────────────────────────╮
Plug '~/.config/nvim/myplugin/ranger.vim'
function! BootstrapPlugConfig.DeployRanger()
	let g:ranger_map_keys = 0
	map <silent> <leader>d :Ranger<CR>
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"╭────────────────────────────────────────────────────────────────────────────╮
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
function! BootstrapPlugConfig.DeploySnippets()
	let g:UltiSnipsExpandTrigger="<tab>"
	let g:UltiSnipsJumpForwardTrigger="<c-u>"
	let g:UltiSnipsJumpBackwardTrigger="<c-o>"
	let g:UltiSnipsSnippetDirectories = [
				\$HOME.'/.config/nvim/Ultisnips/', 
				\$HOME.'/.config/nvim/plugged/vim-snippets/UltiSnips/'
	\]
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

"╭────────────────────────────────────────────────────────────────────────────╮
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
function! BootstrapPlugConfig.DeployAutoformat()
	augroup autoformat_settings
		" autocmd FileType bzl AutoFormatBuffer buildifier
		autocmd FileType c,cpp,proto,javascript,arduino AutoFormatBuffer clang-format
		" autocmd FileType dart AutoFormatBuffer dartfmt
		" autocmd FileType go AutoFormatBuffer gofmt
		" autocmd FileType gn AutoFormatBuffer gn
		" autocmd FileType html,css,sass,scss,less,json AutoFormatBuffer js-beautify
		" autocmd FileType java AutoFormatBuffer google-java-format
		" autocmd FileType python AutoFormatBuffer yapf
		" Alternative: autocmd FileType python AutoFormatBuffer autopep8
		" autocmd FileType rust AutoFormatBuffer rustfmt
		" autocmd FileType vue AutoFormatBuffer prettier
	augroup END
endfunction
"╰────────────────────────────────────────────────────────────────────────────╯

call plug#end()
if empty(glob('~/.config/nvim/plugged'))
	"PlugUpgrade
	PlugInstall
endif

for FuncKey in keys(BootstrapPlugConfig)
	execute 'call BootstrapPlugConfig.'.FuncKey.'()'
endfor

function! s:verify_format_of_line(line)
	let l:re = matchlist(a:line, '\v^\s*%(<autocmd>.*){-}\s*'
				\. '%(hi%(ghlight){-})\s+%(def%(ault){-}\s+){-}(\S+)\s*%(\s*'
										\. '|(<ctermfg>\s*\=\s*(\d+))'
										\. '|(<cterm>\s*\=\s*(none|bold))'
				\. ')+$')
	if empty(l:re) || empty(l:re[3]) || str2nr(l:re[3]) >= 256
		return []
	endif
	return l:re
endfunction

autocmd TextChanged,TextChangedI,TextChangedP,BufEnter *.vim 
			\ call timer_start(50, 
                \ s:update_timer1.clone(bufnr()).task, 
                \ {'repeat': 1})

let s:update_timer1 = {  }
function! s:update_timer1.clone(bufnr) abort
    call setbufvar(a:bufnr, 'hl_code_update_id', 
                \ getbufvar(a:bufnr, 'hl_code_update_id', 0) + 1)
    let l:other_timer       = copy(self)
    let l:other_timer.id    = getbufvar(a:bufnr, 'hl_code_update_id', 0)
    let l:other_timer.bufnr = a:bufnr
    function! l:other_timer.task(timer) abort
        if self.id == getbufvar(self.bufnr, 'hl_code_update_id', 0)
            call setbufvar(self.bufnr, 'hl_code_update_count', 
                    \ getbufvar(self.bufnr, 'hl_code_update_count', 0) + 1)
						call s:color_code_hl()
				endif
    endfunction
    return l:other_timer
endfunction

function! s:color_code_hl()
	let l:lines = getline('^', '$')
	let l:ns_id = nvim_create_namespace(expand('%:t:r').'_color_code_hl_symbols')
	let l:cname_prefix = expand('%:t:r').'_ColorCode_'
	if bufexists(bufnr()) 
		call nvim_buf_clear_namespace(bufnr(), l:ns_id, 0, -1)
	endif
	for idx in range(len(l:lines))
		let l:re = s:verify_format_of_line(l:lines[idx])
		if empty(l:re)
			continue
		endif
		let l:cname = l:cname_prefix.idx
		execute 'hi clear '.l:cname
		execute 'hi '.l:cname. ' '. l:re[2]. ' 'l:re[4]
		call nvim_buf_add_highlight(bufnr(), l:ns_id, l:cname, 
					\ idx, 0, len(l:lines[idx])+1)

		let [str, s, e] = matchstrpos(l:lines[idx], '\v<ctermfg>')
		let l:cname = l:cname_prefix.idx.'_'.s.'_'.e
		execute 'hi '.l:cname. ' ctermfg='. l:re[3]. ' ctermbg='. l:re[3]
		call nvim_buf_add_highlight(bufnr(), l:ns_id, l:cname, idx, s, e)
	endfor
endfunction

autocmd BufReadPost lsp_cxx_highlight.vim call timer_start(100, {->execute(
			\  'botright vsplit ./demo.cpp|exe "normal! \<c-w>h"'
			\)}, {'repeat': 1})
autocmd TextChanged,TextChangedI,TextChangedP lsp_cxx_highlight.vim
			\ call <SID>update_lsp_cxx_hl(getline('.'))
function! s:update_lsp_cxx_hl(line)
	if bufnr('demo.cpp') != -1 && !bufload(bufnr('demo.cpp'))
		let l:re = s:verify_format_of_line(a:line)
		if empty(l:re)
			return
		endif
		execute 'hi clear '.l:re[1]
		execute a:line
	endif
endfunction

