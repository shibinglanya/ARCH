if exists("b:current_syntax")
  finish
endif

" Read the C syntax to start with
runtime! syntax/c.vim
unlet b:current_syntax

" C++ extensions
syn keyword LspCxxHlStatement	new delete this friend using
syn keyword LspCxxHlAccess		public protected private
syn keyword LspCxxHlModifier		inline virtual explicit export
syn keyword LspCxxHlType		bool wchar_t
syn keyword LspCxxHlExceptions	throw try catch
syn keyword LspCxxHlOperator		operator typeid
syn keyword LspCxxHlOperator		and bitor or xor compl bitand and_eq or_eq xor_eq not not_eq
syn match LspCxxHlCast		"\<\(const\|static\|dynamic\|reinterpret\)_cast\s*<"me=e-1
syn match LspCxxHlCast		"\<\(const\|static\|dynamic\|reinterpret\)_cast\s*$"
syn keyword LspCxxHlStorageClass	mutable
syn keyword LspCxxHlStructure	class typename template namespace
syn keyword LspCxxHlBoolean		true false
syn keyword LspCxxHlConstant		__cplusplus

" C++ 11 extensions
if !exists("cpp_no_cpp11")
  syn keyword LspCxxHlModifier	override final
  syn keyword LspCxxHlType		nullptr_t auto
  syn keyword LspCxxHlExceptions	noexcept
  syn keyword LspCxxHlStorageClass	constexpr decltype thread_local
  syn keyword LspCxxHlConstant	nullptr
  syn keyword LspCxxHlConstant	ATOMIC_FLAG_INIT ATOMIC_VAR_INIT
  syn keyword LspCxxHlConstant	ATOMIC_BOOL_LOCK_FREE ATOMIC_CHAR_LOCK_FREE
  syn keyword LspCxxHlConstant	ATOMIC_CHAR16_T_LOCK_FREE ATOMIC_CHAR32_T_LOCK_FREE
  syn keyword LspCxxHlConstant	ATOMIC_WCHAR_T_LOCK_FREE ATOMIC_SHORT_LOCK_FREE
  syn keyword LspCxxHlConstant	ATOMIC_INT_LOCK_FREE ATOMIC_LONG_LOCK_FREE
  syn keyword LspCxxHlConstant	ATOMIC_LLONG_LOCK_FREE ATOMIC_POINTER_LOCK_FREE
  syn region LspCxxHlRawString	matchgroup=LspCxxHlRawStringDelimiter start=+\%(u8\|[uLU]\)\=R"\z([[:alnum:]_{}[\]#<>%:;.?*\+\-/\^&|~!=,"']\{,16}\)(+ end=+)\z1"+ contains=@Spell
endif

" C++ 14 extensions
if !exists("cpp_no_cpp14")
  syn case ignore
  syn match LspCxxHlNumber		display "\<0b[01]\('\=[01]\+\)*\(u\=l\{0,2}\|ll\=u\)\>"
  syn match LspCxxHlNumber		display "\<[1-9]\('\=\d\+\)*\(u\=l\{0,2}\|ll\=u\)\>" contains=cFloat
  syn match LspCxxHlNumber		display "\<0x\x\('\=\x\+\)*\(u\=l\{0,2}\|ll\=u\)\>"
  syn case match
endif

" The minimum and maximum operators in GNU C++
syn match LspCxxHlMinMax "[<>]?"

" Default highlighting
hi def link LspCxxHlAccess		LspCxxHlStatement
hi def link LspCxxHlCast		LspCxxHlStatement
hi def link LspCxxHlExceptions		LspCxxHlKeyword
hi def link LspCxxHlOperator		LspCxxHlKeyword
hi def link LspCxxHlStatement		LspCxxHlKeyword
hi def link LspCxxHlModifier		LspCxxHlKeyword
hi def link LspCxxHlStorageClass	LspCxxHlKeyword
hi def link LspCxxHlStructure		LspCxxHlKeyword
hi def link LspCxxHlBoolean		LspCxxHlLiterals
hi def link LspCxxHlConstant		LspCxxHlLiterals
hi def link LspCxxHlRawDelimiter        LspCxxHlLiterals
hi def link LspCxxHlRawStringDelimiter	LspCxxHlLiterals
hi def link LspCxxHlRawString		LspCxxHlLiterals
hi def link LspCxxHlNumber		LspCxxHlLiterals

source $HOME/.config/nvim/myplugin/lsp_cxx_highlight/syntax/STL_cpp.vim
let b:current_syntax = "cpp"
" vim: ts=8
