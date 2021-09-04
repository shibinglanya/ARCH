if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

let s:ft = matchstr(&ft, '^\([^.]\)\+')

" A bunch of useful C keywords
syntax keyword	LspCxxHlStatement	goto break return continue asm
syntax keyword	LspCxxHlLabel		case default
syntax keyword	LspCxxHlConditional	if else switch
syntax keyword	LspCxxHlRepeat		while for do
syntax keyword	LspCxxHlTodo		contained TODO FIXME XXX

" It's easy to accidentally add a space after a backslash that was intended
" for line continuation.  Some compilers allow it, which makes it
" unpredictable and should be avoided.
syntax match	LspCxxHlBadContinuation contained "\\\s\+$"

" LspCxxHlCommentGroup allows adding matches for special things in comments
syntax cluster	LspCxxHlCommentGroup	contains=LspCxxHlTodo,LspCxxHlBadContinuation

" String and Character constants
" Highlight special characters (those which have a backslash) differently
syntax match	LspCxxHlSpecial	display contained "\\\(x\x\+\|\o\{1,3}\|.\|$\)"
if !exists("c_no_utf")
  syntax match	LspCxxHlSpecial	display contained "\\\(u\x\{4}\|U\x\{8}\)"
endif

if !exists("c_no_cformat")
  " Highlight % items in strings.
  if !exists("c_no_c99") " ISO C99
    syntax match	LspCxxHlFormat		display "%\(\d\+\$\)\=[-+' #0*]*\(\d*\|\*\|\*\d\+\$\)\(\.\(\d*\|\*\|\*\d\+\$\)\)\=\([hlLjzt]\|ll\|hh\)\=\([aAbdiuoxXDOUfFeEgGcCsSpn]\|\[\^\=.[^]]*\]\)" contained
  else
    syntax match	LspCxxHlFormat		display "%\(\d\+\$\)\=[-+' #0*]*\(\d*\|\*\|\*\d\+\$\)\(\.\(\d*\|\*\|\*\d\+\$\)\)\=\([hlL]\|ll\)\=\([bdiuoxXDOUfeEgGcCsSpn]\|\[\^\=.[^]]*\]\)" contained
  endif
  syntax match	LspCxxHlFormat		display "%%" contained
endif

" LspCxxHlCppString: same as LspCxxHlString, but ends at end of line
if s:ft ==# "cpp" && !exists("cpp_no_cpp11") && !exists("c_no_cformat")
  " ISO C++11
  syntax region	LspCxxHlString		start=+\(L\|u\|u8\|U\|R\|LR\|u8R\|uR\|UR\)\="+ skip=+\\\\\|\\"+ end=+"+ contains=LspCxxHlSpecial,LspCxxHlFormat,@Spell extend
  syntax region 	LspCxxHlCppString	start=+\(L\|u\|u8\|U\|R\|LR\|u8R\|uR\|UR\)\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=LspCxxHlSpecial,LspCxxHlFormat,@Spell
elseif s:ft ==# "c" && !exists("c_no_c11") && !exists("c_no_cformat")
  " ISO C99
  syntax region	LspCxxHlString		start=+\%(L\|U\|u8\)\="+ skip=+\\\\\|\\"+ end=+"+ contains=LspCxxHlSpecial,LspCxxHlFormat,@Spell extend
  syntax region	LspCxxHlCppString	start=+\%(L\|U\|u8\)\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=LspCxxHlSpecial,LspCxxHlFormat,@Spell
else
  " older C or C++
  syntax match	LspCxxHlFormat		display "%%" contained
  syntax region	LspCxxHlString		start=+L\="+ skip=+\\\\\|\\"+ end=+"+ contains=LspCxxHlSpecial,LspCxxHlFormat,@Spell extend
  syntax region	LspCxxHlCppString	start=+L\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=LspCxxHlSpecial,LspCxxHlFormat,@Spell
endif

syntax region	LspCxxHlCppSkip	contained start="^\s*\(%:\|#\)\s*\(if\>\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*\(%:\|#\)\s*endif\>" contains=LspCxxHlSpaceError,LspCxxHlCppSkip

syntax cluster	LspCxxHlStringGroup	contains=LspCxxHlCppString,LspCxxHlCppSkip

syntax match	LspCxxHlCharacter	"L\='[^\\]'"
syntax match	LspCxxHlCharacter	"L'[^']*'" contains=LspCxxHlSpecial
if exists("c_gnu")
  syntax match	LspCxxHlSpecialError	"L\='\\[^'\"?\\abefnrtv]'"
  syntax match	LspCxxHlSpecialCharacter "L\='\\['\"?\\abefnrtv]'"
else
  syntax match	LspCxxHlSpecialError	"L\='\\[^'\"?\\abfnrtv]'"
  syntax match	LspCxxHlSpecialCharacter "L\='\\['\"?\\abfnrtv]'"
endif
syntax match	LspCxxHlSpecialCharacter display "L\='\\\o\{1,3}'"
syntax match	LspCxxHlSpecialCharacter display "'\\x\x\{1,2}'"
syntax match	LspCxxHlSpecialCharacter display "L'\\x\x\+'"

if (s:ft ==# "c" && !exists("c_no_c11")) || (s:ft ==# "cpp" && !exists("cpp_no_cpp11"))
  " ISO C11 or ISO C++ 11
  if exists("c_no_cformat")
    syntax region	LspCxxHlString		start=+\%(U\|u8\=\)"+ skip=+\\\\\|\\"+ end=+"+ contains=LspCxxHlSpecial,@Spell extend
  else
    syntax region	LspCxxHlString		start=+\%(U\|u8\=\)"+ skip=+\\\\\|\\"+ end=+"+ contains=LspCxxHlSpecial,LspCxxHlFormat,@Spell extend
  endif
  syntax match	LspCxxHlCharacter	"[Uu]'[^\\]'"
  syntax match	LspCxxHlCharacter	"[Uu]'[^']*'" contains=LspCxxHlSpecial
  if exists("c_gnu")
    syntax match	LspCxxHlSpecialError	"[Uu]'\\[^'\"?\\abefnrtv]'"
    syntax match	LspCxxHlSpecialCharacter "[Uu]'\\['\"?\\abefnrtv]'"
  else
    syntax match	LspCxxHlSpecialError	"[Uu]'\\[^'\"?\\abfnrtv]'"
    syntax match	LspCxxHlSpecialCharacter "[Uu]'\\['\"?\\abfnrtv]'"
  endif
  syntax match	LspCxxHlSpecialCharacter display "[Uu]'\\\o\{1,3}'"
  syntax match	LspCxxHlSpecialCharacter display "[Uu]'\\x\x\+'"
endif

"when wanted, highlight trailing white space
if exists("c_space_errors")
  if !exists("c_no_trail_space_error")
    syntax match	LspCxxHlSpaceError	display excludenl "\s\+$"
  endif
  if !exists("c_no_tab_space_error")
    syntax match	LspCxxHlSpaceError	display " \+\t"me=e-1
  endif
endif

" This should be before LspCxxHlErrInParen to avoid problems with #define ({ xxx })
if exists("c_curly_error")
  syntax match LspCxxHlCurlyError "}"
  syntax region	LspCxxHlBlock		start="{" end="}" contains=ALLBUT,LspCxxHlBadBlock,LspCxxHlCurlyError,@LspCxxHlParenGroup,LspCxxHlErrInParen,LspCxxHlCppParen,LspCxxHlErrInBracket,LspCxxHlCppBracket,@LspCxxHlStringGroup,@Spell fold
else
  syntax region	LspCxxHlBlock		start="{" end="}" transparent fold
endif

" Catch errors caused by wrong parenthesis and brackets.
" Also accept <% for {, %> for }, <: for [ and :> for ] (C99)
" But avoid matching <::.
syntax cluster	LspCxxHlParenGroup	contains=LspCxxHlParenError,LspCxxHlIncluded,LspCxxHlSpecial,LspCxxHlCommentSkip,LspCxxHlCommentString,LspCxxHlComment2String,@LspCxxHlCommentGroup,LspCxxHlCommentStartError,LspCxxHlUserLabel,LspCxxHlBitField,LspCxxHlOctalZero,@LspCxxHlCppOutInGroup,LspCxxHlFormat,LspCxxHlNumber,LspCxxHlFloat,LspCxxHlOctal,LspCxxHlOctalError,LspCxxHlNumbersCom
if exists("c_no_curly_error")
  if s:ft ==# 'cpp' && !exists("cpp_no_cpp11")
    syntax region	LspCxxHlParen		transparent start='(' end=')' contains=ALLBUT,@LspCxxHlParenGroup,LspCxxHlCppParen,@LspCxxHlStringGroup,@Spell
    " LspCxxHlCppParen: same as LspCxxHlParen but ends at end-of-line; used in LspCxxHlDefine
    syntax region	LspCxxHlCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@LspCxxHlParenGroup,LspCxxHlParen,LspCxxHlString,@Spell
    syntax match	LspCxxHlParenError	display ")"
    syntax match	LspCxxHlErrInParen	display contained "^^<%\|^%>"
  else
    syntax region	LspCxxHlParen		transparent start='(' end=')' end='}'me=s-1 contains=ALLBUT,LspCxxHlBlock,@LspCxxHlParenGroup,LspCxxHlCppParen,@LspCxxHlStringGroup,@Spell
    " LspCxxHlCppParen: same as LspCxxHlParen but ends at end-of-line; used in LspCxxHlDefine
    syntax region	LspCxxHlCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@LspCxxHlParenGroup,LspCxxHlParen,LspCxxHlString,@Spell
    syntax match	LspCxxHlParenError	display ")"
    syntax match	LspCxxHlErrInParen	display contained "^[{}]\|^<%\|^%>"
  endif
elseif exists("c_no_bracket_error")
  if s:ft ==# 'cpp' && !exists("cpp_no_cpp11")
    syn region	LspCxxHlParen		transparent start='(' end=')' contains=ALLBUT,@LspCxxHlParenGroup,LspCxxHlCppParen,@LspCxxHlStringGroup,@Spell
    " LspCxxHlCppParen: same as LspCxxHlParen but ends at end-of-line; used in LspCxxHlDefine
    syn region	LspCxxHlCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@LspCxxHlParenGroup,LspCxxHlParen,LspCxxHlString,@Spell
    syn match	LspCxxHlParenError	display ")"
    syn match	LspCxxHlErrInParen	display contained "<%\|%>"
  else
    syn region	LspCxxHlParen		transparent start='(' end=')' end='}'me=s-1 contains=ALLBUT,LspCxxHlBlock,@LspCxxHlParenGroup,LspCxxHlCppParen,@LspCxxHlStringGroup,@Spell
    " LspCxxHlCppParen: same as LspCxxHlParen but ends at end-of-line; used in LspCxxHlDefine
    syn region	LspCxxHlCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@LspCxxHlParenGroup,LspCxxHlParen,LspCxxHlString,@Spell
    syn match	LspCxxHlParenError	display ")"
    syn match	LspCxxHlErrInParen	display contained "[{}]\|<%\|%>"
  endif
else
  if s:ft ==# 'cpp' && !exists("cpp_no_cpp11")
    syn region	LspCxxHlParen		transparent start='(' end=')' contains=ALLBUT,@LspCxxHlParenGroup,LspCxxHlCppParen,LspCxxHlErrInBracket,LspCxxHlCppBracket,@LspCxxHlStringGroup,@Spell
    " LspCxxHlCppParen: same as LspCxxHlParen but ends at end-of-line; used in LspCxxHlDefine
    syn region	LspCxxHlCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@LspCxxHlParenGroup,LspCxxHlErrInBracket,LspCxxHlParen,LspCxxHlBracket,LspCxxHlString,@Spell
    syn match	LspCxxHlParenError	display "[\])]"
    syn match	LspCxxHlErrInParen	display contained "<%\|%>"
    syn region	LspCxxHlBracket	transparent start='\[\|<::\@!' end=']\|:>' contains=ALLBUT,@LspCxxHlParenGroup,LspCxxHlErrInParen,LspCxxHlCppParen,LspCxxHlCppBracket,@LspCxxHlStringGroup,@Spell
  else
    syn region	LspCxxHlParen		transparent start='(' end=')' end='}'me=s-1 contains=ALLBUT,LspCxxHlBlock,@LspCxxHlParenGroup,LspCxxHlCppParen,LspCxxHlErrInBracket,LspCxxHlCppBracket,@LspCxxHlStringGroup,@Spell
    " LspCxxHlCppParen: same as LspCxxHlParen but ends at end-of-line; used in LspCxxHlDefine
    syn region	LspCxxHlCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@LspCxxHlParenGroup,LspCxxHlErrInBracket,LspCxxHlParen,LspCxxHlBracket,LspCxxHlString,@Spell
    syn match	LspCxxHlParenError	display "[\])]"
    syn match	LspCxxHlErrInParen	display contained "[\]{}]\|<%\|%>"
    syn region	LspCxxHlBracket	transparent start='\[\|<::\@!' end=']\|:>' end='}'me=s-1 contains=ALLBUT,LspCxxHlBlock,@LspCxxHlParenGroup,LspCxxHlErrInParen,LspCxxHlCppParen,LspCxxHlCppBracket,@LspCxxHlStringGroup,@Spell
  endif
  " LspCxxHlCppBracket: same as LspCxxHlParen but ends at end-of-line; used in LspCxxHlDefine
  syn region	LspCxxHlCppBracket	transparent start='\[\|<::\@!' skip='\\$' excludenl end=']\|:>' end='$' contained contains=ALLBUT,@LspCxxHlParenGroup,LspCxxHlErrInParen,LspCxxHlParen,LspCxxHlBracket,LspCxxHlString,@Spell
  syn match	LspCxxHlErrInBracket	display contained "[);{}]\|<%\|%>"
endif

if s:ft ==# 'c' || exists("cpp_no_cpp11")
  syn region	LspCxxHlBadBlock	keepend start="{" end="}" contained containedin=LspCxxHlParen,LspCxxHlBracket,LspCxxHlBadBlock transparent fold
endif

"integer number, or floating point number without a dot and with "f".
syn case ignore
syn match	LspCxxHlNumbers	display transparent "\<\d\|\.\d" contains=LspCxxHlNumber,LspCxxHlFloat,LspCxxHlOctalError,LspCxxHlOctal
" Same, but without octal error (for comments)
syn match	LspCxxHlNumbersCom	display contained transparent "\<\d\|\.\d" contains=LspCxxHlNumber,LspCxxHlFloat,LspCxxHlOctal
syn match	LspCxxHlNumber		display contained "\d\+\(u\=l\{0,2}\|ll\=u\)\>"
"hex number
syn match	LspCxxHlNumber		display contained "0x\x\+\(u\=l\{0,2}\|ll\=u\)\>"
" Flag the first zero of an octal number as something special
syn match	LspCxxHlOctal		display contained "0\o\+\(u\=l\{0,2}\|ll\=u\)\>" contains=LspCxxHlOctalZero
syn match	LspCxxHlOctalZero	display contained "\<0"
syn match	LspCxxHlFloat		display contained "\d\+f"
"floating point number, with dot, optional exponent
syn match	LspCxxHlFloat		display contained "\d\+\.\d*\(e[-+]\=\d\+\)\=[fl]\="
"floating point number, starting with a dot, optional exponent
syn match	LspCxxHlFloat		display contained "\.\d\+\(e[-+]\=\d\+\)\=[fl]\=\>"
"floating point number, without dot, with exponent
syn match	LspCxxHlFloat		display contained "\d\+e[-+]\=\d\+[fl]\=\>"
if !exists("c_no_c99")
  "hexadecimal floating point number, optional leading digits, with dot, with exponent
  syn match	LspCxxHlFloat		display contained "0x\x*\.\x\+p[-+]\=\d\+[fl]\=\>"
  "hexadecimal floating point number, with leading digits, optional dot, with exponent
  syn match	LspCxxHlFloat		display contained "0x\x\+\.\=p[-+]\=\d\+[fl]\=\>"
endif

" flag an octal number with wrong digits
syn match	LspCxxHlOctalError	display contained "0\o*[89]\d*"
syn case match

if exists("c_comment_strings")
  " A comment can contain LspCxxHlString, LspCxxHlCharacter and LspCxxHlNumber.
  " But a "*/" inside a LspCxxHlString in a LspCxxHlComment DOES end the comment!  So we
  " need to use a special type of LspCxxHlString: LspCxxHlCommentString, which also ends on
  " "*/", and sees a "*" at the start of the line as comment again.
  " Unfortunately this doesn't very well work for // type of comments :-(
  syn match	LspCxxHlCommentSkip	contained "^\s*\*\($\|\s\+\)"
  syn region LspCxxHlCommentString	contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end=+\*/+me=s-1 contains=LspCxxHlSpecial,LspCxxHlCommentSkip
  syn region LspCxxHlComment2String	contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end="$" contains=LspCxxHlSpecial
  syn region  LspCxxHlCommentL	start="//" skip="\\$" end="$" keepend contains=@LspCxxHlCommentGroup,LspCxxHlComment2String,LspCxxHlCharacter,LspCxxHlNumbersCom,LspCxxHlSpaceError,LspCxxHlWrongComTail,@Spell
  if exists("c_no_comment_fold")
    " Use "extend" here to have preprocessor lines not terminate halfway a
    " comment.
    syn region LspCxxHlComment	matchgroup=LspCxxHlCommentStart start="/\*" end="\*/" contains=@LspCxxHlCommentGroup,LspCxxHlCommentStartError,LspCxxHlCommentString,LspCxxHlCharacter,LspCxxHlNumbersCom,LspCxxHlSpaceError,@Spell extend
  else
    syn region LspCxxHlComment	matchgroup=LspCxxHlCommentStart start="/\*" end="\*/" contains=@LspCxxHlCommentGroup,LspCxxHlCommentStartError,LspCxxHlCommentString,LspCxxHlCharacter,LspCxxHlNumbersCom,LspCxxHlSpaceError,@Spell fold extend
  endif
else
  syn region	LspCxxHlCommentL	start="//" skip="\\$" end="$" keepend contains=@LspCxxHlCommentGroup,LspCxxHlSpaceError,@Spell
  if exists("c_no_comment_fold")
    syn region	LspCxxHlComment	matchgroup=LspCxxHlCommentStart start="/\*" end="\*/" contains=@LspCxxHlCommentGroup,LspCxxHlCommentStartError,LspCxxHlSpaceError,@Spell extend
  else
    syn region	LspCxxHlComment	matchgroup=LspCxxHlCommentStart start="/\*" end="\*/" contains=@LspCxxHlCommentGroup,LspCxxHlCommentStartError,LspCxxHlSpaceError,@Spell fold extend
  endif
endif
" keep a // comment separately, it terminates a preproc. conditional
syn match	LspCxxHlCommentError	display "\*/"
syn match	LspCxxHlCommentStartError display "/\*"me=e-1 contained
syn match	LspCxxHlWrongComTail	display "\*/"

syn keyword	LspCxxHlOperator	sizeof
if exists("c_gnu")
  syn keyword	LspCxxHlStatement	__asm__
  syn keyword	LspCxxHlOperator	typeof __real__ __imag__
endif
syn keyword	LspCxxHlType		int long short char void
syn keyword	LspCxxHlType		signed unsigned float double
if !exists("c_no_ansi") || exists("c_ansi_typedefs")
  syn keyword   LspCxxHlType		size_t ssize_t off_t wchar_t ptrdiff_t sig_atomic_t fpos_t
  syn keyword   LspCxxHlType		clock_t time_t va_list jmp_buf FILE DIR div_t ldiv_t
  syn keyword   LspCxxHlType		mbstate_t wctrans_t wint_t wctype_t
endif
if !exists("c_no_c99") " ISO C99
  syn keyword	LspCxxHlType		_Bool bool _Complex complex _Imaginary imaginary
  syn keyword	LspCxxHlType		int8_t int16_t int32_t int64_t
  syn keyword	LspCxxHlType		uint8_t uint16_t uint32_t uint64_t
  if !exists("c_no_bsd")
    " These are BSD specific.
    syn keyword	LspCxxHlType		u_int8_t u_int16_t u_int32_t u_int64_t
  endif
  syn keyword	LspCxxHlType		int_least8_t int_least16_t int_least32_t int_least64_t
  syn keyword	LspCxxHlType		uint_least8_t uint_least16_t uint_least32_t uint_least64_t
  syn keyword	LspCxxHlType		int_fast8_t int_fast16_t int_fast32_t int_fast64_t
  syn keyword	LspCxxHlType		uint_fast8_t uint_fast16_t uint_fast32_t uint_fast64_t
  syn keyword	LspCxxHlType		intptr_t uintptr_t
  syn keyword	LspCxxHlType		intmax_t uintmax_t
endif
if exists("c_gnu")
  syn keyword	LspCxxHlType		__label__ __complex__ __volatile__
endif

syn keyword	LspCxxHlStructure	struct union enum typedef
syn match       LspCxxHlType           /\v<const>/

syn match       LspCxxHlStorageClass   /\v<const\s*($|;|\{)@=/
syn keyword	LspCxxHlStorageClass	static register auto volatile extern

if exists("c_gnu")
  syn keyword	LspCxxHlStorageClass	inline __attribute__
endif
if !exists("c_no_c99") && s:ft !=# 'cpp'
  syn keyword	LspCxxHlStorageClass	inline restrict
endif
if !exists("c_no_c11")
  syn keyword	LspCxxHlStorageClass	_Alignas alignas
  syn keyword	LspCxxHlOperator	_Alignof alignof
  syn keyword	LspCxxHlStorageClass	_Atomic
  syn keyword	LspCxxHlOperator	_Generic
  syn keyword	LspCxxHlStorageClass	_Noreturn noreturn
  syn keyword	LspCxxHlOperator	_Static_assert static_assert
  syn keyword	LspCxxHlStorageClass	_Thread_local thread_local
  syn keyword   LspCxxHlType		char16_t char32_t
  " C11 atomics (take down the shield wall!)
  syn keyword	LspCxxHlType		atomic_bool atomic_char atomic_schar atomic_uchar
  syn keyword	Ctype		atomic_short atomic_ushort atomic_int atomic_uint
  syn keyword	LspCxxHlType		atomic_long atomic_ulong atomic_llong atomic_ullong
  syn keyword	LspCxxHlType		atomic_char16_t atomic_char32_t atomic_wchar_t
  syn keyword	LspCxxHlType		atomic_int_least8_t atomic_uint_least8_t
  syn keyword	LspCxxHlType		atomic_int_least16_t atomic_uint_least16_t
  syn keyword	LspCxxHlType		atomic_int_least32_t atomic_uint_least32_t
  syn keyword	LspCxxHlType		atomic_int_least64_t atomic_uint_least64_t
  syn keyword	LspCxxHlType		atomic_int_fast8_t atomic_uint_fast8_t
  syn keyword	LspCxxHlType		atomic_int_fast16_t atomic_uint_fast16_t
  syn keyword	LspCxxHlType		atomic_int_fast32_t atomic_uint_fast32_t
  syn keyword	LspCxxHlType		atomic_int_fast64_t atomic_uint_fast64_t
  syn keyword	LspCxxHlType		atomic_intptr_t atomic_uintptr_t
  syn keyword	LspCxxHlType		atomic_size_t atomic_ptrdiff_t
  syn keyword	LspCxxHlType		atomic_intmax_t atomic_uintmax_t
endif

if !exists("c_no_ansi") || exists("c_ansi_constants") || exists("c_gnu")
  if exists("c_gnu")
    syn keyword LspCxxHlConstant __GNUC__ __FUNCTION__ __PRETTY_FUNCTION__ __func__
  endif
  syn keyword LspCxxHlConstant __LINE__ __FILE__ __DATE__ __TIME__ __STDC__
  syn keyword LspCxxHlConstant __STDC_VERSION__
  syn keyword LspCxxHlConstant CHAR_BIT MB_LEN_MAX MB_CUR_MAX
  syn keyword LspCxxHlConstant UCHAR_MAX UINT_MAX ULONG_MAX USHRT_MAX
  syn keyword LspCxxHlConstant CHAR_MIN INT_MIN LONG_MIN SHRT_MIN
  syn keyword LspCxxHlConstant CHAR_MAX INT_MAX LONG_MAX SHRT_MAX
  syn keyword LspCxxHlConstant SCHAR_MIN SINT_MIN SLONG_MIN SSHRT_MIN
  syn keyword LspCxxHlConstant SCHAR_MAX SINT_MAX SLONG_MAX SSHRT_MAX
  if !exists("c_no_c99")
    syn keyword LspCxxHlConstant __func__ __VA_ARGS__
    syn keyword LspCxxHlConstant LLONG_MIN LLONG_MAX ULLONG_MAX
    syn keyword LspCxxHlConstant INT8_MIN INT16_MIN INT32_MIN INT64_MIN
    syn keyword LspCxxHlConstant INT8_MAX INT16_MAX INT32_MAX INT64_MAX
    syn keyword LspCxxHlConstant UINT8_MAX UINT16_MAX UINT32_MAX UINT64_MAX
    syn keyword LspCxxHlConstant INT_LEAST8_MIN INT_LEAST16_MIN INT_LEAST32_MIN INT_LEAST64_MIN
    syn keyword LspCxxHlConstant INT_LEAST8_MAX INT_LEAST16_MAX INT_LEAST32_MAX INT_LEAST64_MAX
    syn keyword LspCxxHlConstant UINT_LEAST8_MAX UINT_LEAST16_MAX UINT_LEAST32_MAX UINT_LEAST64_MAX
    syn keyword LspCxxHlConstant INT_FAST8_MIN INT_FAST16_MIN INT_FAST32_MIN INT_FAST64_MIN
    syn keyword LspCxxHlConstant INT_FAST8_MAX INT_FAST16_MAX INT_FAST32_MAX INT_FAST64_MAX
    syn keyword LspCxxHlConstant UINT_FAST8_MAX UINT_FAST16_MAX UINT_FAST32_MAX UINT_FAST64_MAX
    syn keyword LspCxxHlConstant INTPTR_MIN INTPTR_MAX UINTPTR_MAX
    syn keyword LspCxxHlConstant INTMAX_MIN INTMAX_MAX UINTMAX_MAX
    syn keyword LspCxxHlConstant PTRDIFF_MIN PTRDIFF_MAX SIG_ATOMIC_MIN SIG_ATOMIC_MAX
    syn keyword LspCxxHlConstant SIZE_MAX WCHAR_MIN WCHAR_MAX WINT_MIN WINT_MAX
  endif
  syn keyword LspCxxHlConstant FLT_RADIX FLT_ROUNDS FLT_DIG FLT_MANT_DIG FLT_EPSILON DBL_DIG DBL_MANT_DIG DBL_EPSILON
  syn keyword LspCxxHlConstant LDBL_DIG LDBL_MANT_DIG LDBL_EPSILON FLT_MIN FLT_MAX FLT_MIN_EXP FLT_MAX_EXP FLT_MIN_10_EXP FLT_MAX_10_EXP
  syn keyword LspCxxHlConstant DBL_MIN DBL_MAX DBL_MIN_EXP DBL_MAX_EXP DBL_MIN_10_EXP DBL_MAX_10_EXP LDBL_MIN LDBL_MAX LDBL_MIN_EXP LDBL_MAX_EXP
  syn keyword LspCxxHlConstant LDBL_MIN_10_EXP LDBL_MAX_10_EXP HUGE_VAL CLOCKS_PER_SEC NULL LC_ALL LC_COLLATE LC_CTYPE LC_MONETARY
  syn keyword LspCxxHlConstant LC_NUMERIC LC_TIME SIG_DFL SIG_ERR SIG_IGN SIGABRT SIGFPE SIGILL SIGHUP SIGINT SIGSEGV SIGTERM
  " Add POSIX signals as well...
  syn keyword LspCxxHlConstant SIGABRT SIGALRM SIGCHLD SIGCONT SIGFPE SIGHUP SIGILL SIGINT SIGKILL SIGPIPE SIGQUIT SIGSEGV
  syn keyword LspCxxHlConstant SIGSTOP SIGTERM SIGTRAP SIGTSTP SIGTTIN SIGTTOU SIGUSR1 SIGUSR2
  syn keyword LspCxxHlConstant _IOFBF _IOLBF _IONBF BUFSIZ EOF WEOF FOPEN_MAX FILENAME_MAX L_tmpnam
  syn keyword LspCxxHlConstant SEEK_CUR SEEK_END SEEK_SET TMP_MAX stderr stdin stdout EXIT_FAILURE EXIT_SUCCESS RAND_MAX
  " POSIX 2001
  syn keyword LspCxxHlConstant SIGBUS SIGPOLL SIGPROF SIGSYS SIGURG SIGVTALRM SIGXCPU SIGXFSZ
  " non-POSIX signals
  syn keyword LspCxxHlConstant SIGWINCH SIGINFO
  " Add POSIX errors as well.  List comes from:
  " http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/errno.h.html
  syn keyword LspCxxHlConstant E2BIG EACCES EADDRINUSE EADDRNOTAVAIL EAFNOSUPPORT EAGAIN EALREADY EBADF
  syn keyword LspCxxHlConstant EBADMSG EBUSY ECANCELED ECHILD ECONNABORTED ECONNREFUSED ECONNRESET EDEADLK
  syn keyword LspCxxHlConstant EDESTADDRREQ EDOM EDQUOT EEXIST EFAULT EFBIG EHOSTUNREACH EIDRM EILSEQ
  syn keyword LspCxxHlConstant EINPROGRESS EINTR EINVAL EIO EISCONN EISDIR ELOOP EMFILE EMLINK EMSGSIZE
  syn keyword LspCxxHlConstant EMULTIHOP ENAMETOOLONG ENETDOWN ENETRESET ENETUNREACH ENFILE ENOBUFS ENODATA
  syn keyword LspCxxHlConstant ENODEV ENOENT ENOEXEC ENOLCK ENOLINK ENOMEM ENOMSG ENOPROTOOPT ENOSPC ENOSR
  syn keyword LspCxxHlConstant ENOSTR ENOSYS ENOTBLK ENOTCONN ENOTDIR ENOTEMPTY ENOTRECOVERABLE ENOTSOCK ENOTSUP
  syn keyword LspCxxHlConstant ENOTTY ENXIO EOPNOTSUPP EOVERFLOW EOWNERDEAD EPERM EPIPE EPROTO
  syn keyword LspCxxHlConstant EPROTONOSUPPORT EPROTOTYPE ERANGE EROFS ESPIPE ESRCH ESTALE ETIME ETIMEDOUT
  syn keyword LspCxxHlConstant ETXTBSY EWOULDBLOCK EXDEV
  " math.h
  syn keyword LspCxxHlConstant M_E M_LOG2E M_LOG10E M_LN2 M_LN10 M_PI M_PI_2 M_PI_4
  syn keyword LspCxxHlConstant M_1_PI M_2_PI M_2_SQRTPI M_SQRT2 M_SQRT1_2
endif
if !exists("c_no_c99") " ISO C99
  syn keyword LspCxxHlConstant true false
endif

" Accept %: for # (C99)
syn region	LspCxxHlPreCondit	start="^\s*\zs\(%:\|#\)\s*\(if\|ifdef\|ifndef\|elif\)\>" skip="\\$" end="$" keepend contains=LspCxxHlComment,LspCxxHlCommentL,LspCxxHlCppString,LspCxxHlCharacter,LspCxxHlCppParen,LspCxxHlParenError,LspCxxHlNumbers,LspCxxHlCommentError,LspCxxHlSpaceError
syn match	LspCxxHlPreConditMatch	display "^\s*\zs\(%:\|#\)\s*\(else\|endif\)\>"
if !exists("c_no_if0")
  syn cluster	LspCxxHlCppOutInGroup	contains=LspCxxHlCppInIf,LspCxxHlCppInElse,LspCxxHlCppInElse2,LspCxxHlCppOutIf,LspCxxHlCppOutIf2,LspCxxHlCppOutElse,LspCxxHlCppInSkip,LspCxxHlCppOutSkip
  syn region	LspCxxHlCppOutWrapper	start="^\s*\zs\(%:\|#\)\s*if\s\+0\+\s*\($\|//\|/\*\|&\)" end=".\@=\|$" contains=LspCxxHlCppOutIf,LspCxxHlCppOutElse,@NoSpell fold
  syn region	LspCxxHlCppOutIf	contained start="0\+" matchgroup=LspCxxHlCppOutWrapper end="^\s*\(%:\|#\)\s*endif\>" contains=LspCxxHlCppOutIf2,LspCxxHlCppOutElse
  if !exists("c_no_if0_fold")
    syn region	LspCxxHlCppOutIf2	contained matchgroup=LspCxxHlCppOutWrapper start="0\+" end="^\s*\(%:\|#\)\s*\(else\>\|elif\s\+\(0\+\s*\($\|//\|/\*\|&\)\)\@!\|endif\>\)"me=s-1 contains=LspCxxHlSpaceError,LspCxxHlCppOutSkip,@Spell fold
  else
    syn region	LspCxxHlCppOutIf2	contained matchgroup=LspCxxHlCppOutWrapper start="0\+" end="^\s*\(%:\|#\)\s*\(else\>\|elif\s\+\(0\+\s*\($\|//\|/\*\|&\)\)\@!\|endif\>\)"me=s-1 contains=LspCxxHlSpaceError,LspCxxHlCppOutSkip,@Spell
  endif
  syn region	LspCxxHlCppOutElse	contained matchgroup=LspCxxHlCppOutWrapper start="^\s*\(%:\|#\)\s*\(else\|elif\)" end="^\s*\(%:\|#\)\s*endif\>"me=s-1 contains=TOP,LspCxxHlPreCondit
  syn region	LspCxxHlCppInWrapper	start="^\s*\zs\(%:\|#\)\s*if\s\+0*[1-9]\d*\s*\($\|//\|/\*\||\)" end=".\@=\|$" contains=LspCxxHlCppInIf,LspCxxHlCppInElse fold
  syn region	LspCxxHlCppInIf	contained matchgroup=LspCxxHlCppInWrapper start="\d\+" end="^\s*\(%:\|#\)\s*endif\>" contains=TOP,LspCxxHlPreCondit
  if !exists("c_no_if0_fold")
    syn region	LspCxxHlCppInElse	contained start="^\s*\(%:\|#\)\s*\(else\>\|elif\s\+\(0*[1-9]\d*\s*\($\|//\|/\*\||\)\)\@!\)" end=".\@=\|$" containedin=LspCxxHlCppInIf contains=LspCxxHlCppInElse2 fold
  else
    syn region	LspCxxHlCppInElse	contained start="^\s*\(%:\|#\)\s*\(else\>\|elif\s\+\(0*[1-9]\d*\s*\($\|//\|/\*\||\)\)\@!\)" end=".\@=\|$" containedin=LspCxxHlCppInIf contains=LspCxxHlCppInElse2
  endif
  syn region	LspCxxHlCppInElse2	contained matchgroup=LspCxxHlCppInWrapper start="^\s*\(%:\|#\)\s*\(else\|elif\)\([^/]\|/[^/*]\)*" end="^\s*\(%:\|#\)\s*endif\>"me=s-1 contains=LspCxxHlSpaceError,LspCxxHlCppOutSkip,@Spell
  syn region	LspCxxHlCppOutSkip	contained start="^\s*\(%:\|#\)\s*\(if\>\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*\(%:\|#\)\s*endif\>" contains=LspCxxHlSpaceError,LspCxxHlCppOutSkip
  syn region	LspCxxHlCppInSkip	contained matchgroup=LspCxxHlCppInWrapper start="^\s*\(%:\|#\)\s*\(if\s\+\(\d\+\s*\($\|//\|/\*\||\|&\)\)\@!\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*\(%:\|#\)\s*endif\>" containedin=LspCxxHlCppOutElse,LspCxxHlCppInIf,LspCxxHlCppInSkip contains=TOP,LspCxxHlPreProc
endif
syn region	LspCxxHlIncluded	display contained start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match	LspCxxHlIncluded	display contained "<[^>]*>"
syn match	LspCxxHlInclude	display "^\s*\zs\(%:\|#\)\s*include\>\s*["<]" contains=LspCxxHlIncluded
"syn match LspCxxHlLineSkip	"\\$"
syn cluster	LspCxxHlPreProLspCxxHlGroup	contains=LspCxxHlPreCondit,LspCxxHlIncluded,LspCxxHlInclude,LspCxxHlDefine,LspCxxHlErrInParen,LspCxxHlErrInBracket,LspCxxHlUserLabel,LspCxxHlSpecial,LspCxxHlOctalZero,LspCxxHlCppOutWrapper,LspCxxHlCppInWrapper,@LspCxxHlCppOutInGroup,LspCxxHlFormat,LspCxxHlNumber,LspCxxHlFloat,LspCxxHlOctal,LspCxxHlOctalError,LspCxxHlNumbersCom,LspCxxHlString,LspCxxHlCommentSkip,LspCxxHlCommentString,LspCxxHlComment2String,@LspCxxHlCommentGroup,LspCxxHlCommentStartError,LspCxxHlParen,LspCxxHlBracket,LspCxxHlMulti,LspCxxHlBadBlock
syn region	LspCxxHlDefine		start="^\s*\zs\(%:\|#\)\s*\(define\|undef\)\>" skip="\\$" end="$" keepend contains=ALLBUT,@LspCxxHlPreProLspCxxHlGroup,@Spell
syn region	LspCxxHlPreProc	start="^\s*\zs\(%:\|#\)\s*\(pragma\>\|line\>\|warning\>\|warn\>\|error\>\)" skip="\\$" end="$" keepend contains=ALLBUT,@LspCxxHlPreProLspCxxHlGroup,@Spell

" Optional embedded Autodoc parsing
if exists("c_autodoc")
  syn match LspCxxHlAutodoLspCxxHlReal display contained "\%(//\|[/ \t\v]\*\|^\*\)\@2<=!.*" contains=@LspCxxHlAutodoc containedin=LspCxxHlComment,LspCxxHlCommentL
  syn cluster LspCxxHlCommentGroup add=LspCxxHlAutodoLspCxxHlReal
  syn cluster LspCxxHlPreProLspCxxHlGroup add=LspCxxHlAutodoLspCxxHlReal
endif

" Highlight User Labels
syn cluster	LspCxxHlMultiGroup	contains=LspCxxHlIncluded,LspCxxHlSpecial,LspCxxHlCommentSkip,LspCxxHlCommentString,LspCxxHlComment2String,@LspCxxHlCommentGroup,LspCxxHlCommentStartError,LspCxxHlUserCont,LspCxxHlUserLabel,LspCxxHlBitField,LspCxxHlOctalZero,LspCxxHlCppOutWrapper,LspCxxHlCppInWrapper,@LspCxxHlCppOutInGroup,LspCxxHlFormat,LspCxxHlNumber,LspCxxHlFloat,LspCxxHlOctal,LspCxxHlOctalError,LspCxxHlNumbersCom,LspCxxHlCppParen,LspCxxHlCppBracket,LspCxxHlCppString
if s:ft ==# 'c' || exists("cpp_no_cpp11")
  syn region	LspCxxHlMulti		transparent start='?' skip='::' end=':' contains=ALLBUT,@LspCxxHlMultiGroup,@Spell,@LspCxxHlStringGroup
endif
" Avoid matching foo::bar() in C++ by requiring that the next char is not ':'
syn cluster	LspCxxHlLabelGroup	contains=LspCxxHlUserLabel
syn match	LspCxxHlUserCont	display "^\s*\zs\I\i*\s*:$" contains=@LspCxxHlLabelGroup
syn match	LspCxxHlUserCont	display ";\s*\zs\I\i*\s*:$" contains=@LspCxxHlLabelGroup
if s:ft ==# 'cpp'
  syn match	LspCxxHlUserCont	display "^\s*\zs\%(class\|struct\|enum\)\@!\I\i*\s*:[^:]"me=e-1 contains=@LspCxxHlLabelGroup
  syn match	LspCxxHlUserCont	display ";\s*\zs\%(class\|struct\|enum\)\@!\I\i*\s*:[^:]"me=e-1 contains=@LspCxxHlLabelGroup
else
  syn match	LspCxxHlUserCont	display "^\s*\zs\I\i*\s*:[^:]"me=e-1 contains=@LspCxxHlLabelGroup
  syn match	LspCxxHlUserCont	display ";\s*\zs\I\i*\s*:[^:]"me=e-1 contains=@LspCxxHlLabelGroup
endif

syn match	LspCxxHlUserLabel	display "\I\i*" contained

" Avoid recognizing most bitfields as labels
syn match	LspCxxHlBitField	display "^\s*\zs\I\i*\s*:\s*[1-9]"me=e-1 contains=LspCxxHlType
syn match	LspCxxHlBitField	display ";\s*\zs\I\i*\s*:\s*[1-9]"me=e-1 contains=LspCxxHlType

if exists("c_minlines")
  let b:c_minlines = c_minlines
else
  if !exists("c_no_if0")
    let b:c_minlines = 50	" #if 0 constructs can be long
  else
    let b:c_minlines = 15	" mostly for () constructs
  endif
endif
if exists("c_curly_error")
  syn sync fromstart
else
  exec "syn sync ccomment LspCxxHlComment minlines=" . b:c_minlines
endif

"查询高亮组
"nnoremap <f1> :echo synIDattr(synID(line('.'), col('.'), 0), 'name')<cr>
"nnoremap <f2> :echo ("hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
"\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
"\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">")<cr>
"nnoremap <f3> :echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')<cr>
"nnoremap <f4> :exec 'syn list '.synIDattr(synID(line('.'), col('.'), 0), 'name')<cr>

" Define the default highlighting.
" Only used when an item doesn't have highlighting yet
"
hi def link LspCxxHlStorageClass     LspCxxHlKeyword
hi def link LspCxxHlStructure        LspCxxHlKeyword
hi def link LspCxxHlOperator         LspCxxHlKeyword
hi def link LspCxxHlStatement	LspCxxHlKeyword
hi def link LspCxxHlRepeat		LspCxxHlKeyword
hi def link LspCxxHlLabel		LspCxxHlKeyword
hi def link LspCxxHlConditional	LspCxxHlKeyword

hi def link LspCxxHlSpecial          LspCxxHlLiterals
hi def link LspCxxHlIncluded		LspCxxHlLiterals
hi def link LspCxxHlConstant		LspCxxHlLiterals
hi def link LspCxxHlCommentString	LspCxxHlLiterals
hi def link LspCxxHlComment2String	LspCxxHlLiterals
hi def link LspCxxHlCharacter	LspCxxHlLiterals
hi def link LspCxxHlSpecialCharacter	LspCxxHlLiterals
hi def link LspCxxHlNumber		LspCxxHlLiterals
hi def link LspCxxHlOctal		LspCxxHlLiterals
hi def link LspCxxHlFloat    	LspCxxHlLiterals
hi def link LspCxxHlString		LspCxxHlLiterals
hi def link LspCxxHlCppString	LspCxxHlLiterals

hi def link LspCxxHlCommentL		LspCxxHlComment
hi def link LspCxxHlCommentStart	LspCxxHlComment
hi def link LspCxxHlCommentSkip	LspCxxHlComment
hi def link LspCxxHlCppOutSkip	LspCxxHlCppOutIf2
hi def link LspCxxHlCppInElse2	LspCxxHlCppOutIf2
hi def link LspCxxHlCppOutIf2	LspCxxHlCppOut
hi def link LspCxxHlCppOut		LspCxxHlComment

hi def link LspCxxHlCppOutWrapper           LspCxxHlMacro
hi def link LspCxxHlInclude		LspCxxHlMacro
hi def link LspCxxHlPreCondit	LspCxxHlMacro
hi def link LspCxxHlPreProc		LspCxxHlMacro
hi def link LspCxxHlDefine		LspCxxHlMacro
hi def link LspCxxHlPreConditMatch		LspCxxHlMacro

hi def link LspCxxHlBadContinuation	        LspCxxHlError
hi def link LspCxxHlOctalZero		LspCxxHlError	 " link this to Error if you want
hi def link LspCxxHlOctalError		LspCxxHlError
hi def link LspCxxHlParenError		LspCxxHlError
hi def link LspCxxHlErrInParen		LspCxxHlError
hi def link LspCxxHlErrInBracket	        LspCxxHlError
hi def link LspCxxHlCommentError	        LspCxxHlError
hi def link LspCxxHlCommentStartError	LspCxxHlError
hi def link LspCxxHlSpaceError		LspCxxHlError
hi def link LspCxxHlWrongComTail	        LspCxxHlError
hi def link LspCxxHlSpecialError	        LspCxxHlError
hi def link LspCxxHlCurlyError		LspCxxHlError

let b:current_syntax = "c"

unlet s:ft

let &cpo = s:cpo_save
unlet s:cpo_save
" vim: ts=8
