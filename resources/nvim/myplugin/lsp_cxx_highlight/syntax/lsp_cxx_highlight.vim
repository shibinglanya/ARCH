hi def LspCxxHlKeyword          ctermfg=2
hi def LspCxxHlLiterals         ctermfg=214
hi def LspCxxHlComment	        ctermfg=243
hi def LspCxxHlType		        ctermfg=110
hi def LspCxxHlUserLabel	    ctermfg=none
hi def LspCxxHlMacro           ctermfg=2
hi def LspCxxHlTodo		        ctermfg=123
hi def LspCxxHlError            ctermfg=Red
hi def LspCxxHlFormat		    ctermfg=30
hi def LspCxxHlCppInWrapper	    ctermfg=none
hi def LspCxxHlCppOutWrapper	ctermfg=none


hi default link LspCxxHlSymClass           LspCxxHlType
hi default link LspCxxHlSymStruct          LspCxxHlType
hi default link LspCxxHlSymEnum            LspCxxHlType
hi default link LspCxxHlSymTypeAlias       LspCxxHlType
hi default link LspCxxHlSymTypeParameter   LspCxxHlType
hi def LspCxxHlSymFunction ctermfg=1
hi def LspCxxHlSymStaticMethod ctermfg=1
hi def LspCxxHlSymEnumMember ctermfg=214
hi def LspCxxHlSymNamespace ctermfg=7
hi def LspCxxHlSymParameter ctermfg=White
hi def LspCxxHlSymMacro           ctermfg=214
hi def LspCxxHlSkippedRegion ctermfg=243

"class的构造函数, 对struct声明的没有效果（原因未知）
hi def LspCxxHlSymConstructor     ctermfg=110

"成员函数和变量
hi def LspCxxHlSymMethod ctermfg=5
hi def LspCxxHlSymField ctermfg=5
hi def LspCxxHlSymClassVariableStatic ctermfg=3

"全局外部变量
hi def LspCxxHlSymFileVariable ctermfg=3
hi def LspCxxHlSymUnknownVariable ctermfg=3
hi def LspCxxHlSymNamespaceVariable ctermfg=3

"全局私有变量
hi def LspCxxHlSymFileVariableStatic ctermfg=165
hi def LspCxxHlSymNamespaceVariableStatic ctermfg=165
hi def LspCxxHlSymFunctionVariableStatic ctermfg=165
hi def LspCxxHlSymStaticMethodVariableStatic ctermfg=165

"函数中的局部变量
hi def LspCxxHlSymVariable ctermfg=6

"" Default syntax
"" Customizing:
"" to change the highlighting of a group add this to your vimrc.
""
"" E.g. Change Preprocessor skipped regions to red bold text
"" hi LspCxxHlSkippedRegion cterm=Red guifg=#FF0000 cterm=bold gui=bold
""
"" E.g. Change Variables to be highlighted as Identifiers
"" hi link LspCxxHlSymVariable Identifier
"
"
"" Preprocessor Skipped Regions:
""
"" This is used for false branches of #if or other preprocessor conditions
"hi default link LspCxxHlSkippedRegion Comment
"
"" This is the first and last line of the preprocessor regions
"" in most cases this contains the #if/#else/#endif statements
"" so it is better to let syntax do the highlighting.
"hi default link LspCxxHlSkippedRegionBeginEnd Normal
"
"
"" Syntax Highlighting:
""
"" Custom Highlight Groups
"hi default LspCxxHlGroupEnumConstant ctermfg=Magenta guifg=#AD7FA8 cterm=none gui=none
"hi default LspCxxHlGroupNamespace ctermfg=Yellow guifg=#BBBB00 cterm=none gui=none
"hi default LspCxxHlGroupMemberVariable ctermfg=White guifg=White
"
"文件第一次进入，宏不能正确显示颜色～这是个取巧的办法！！！
"目前来说，还没有什么问题，保佑我吧～～～
hi default link LspCxxHlSymUnknown LspCxxHlSymMacro
"
"" Type
"hi default link LspCxxHlSymClass Type
"hi default link LspCxxHlSymStruct Type
"hi default link LspCxxHlSymEnum Type
"hi default link LspCxxHlSymTypeAlias Type
"hi default link LspCxxHlSymTypeParameter Type
"
"" Function
"hi default link LspCxxHlSymFunction Function
"hi default link LspCxxHlSymMethod Function
"hi default link LspCxxHlSymStaticMethod Function
"hi default link LspCxxHlSymConstructor Function
"
"" EnumConstant
"hi default link LspCxxHlSymEnumMember LspCxxHlGroupEnumConstant
"
"" Preprocessor
"hi default link LspCxxHlSymMacro Macro
"
"" Namespace
"hi default link LspCxxHlSymNamespace LspCxxHlGroupNamespace
"
"" Variables
"hi default link LspCxxHlSymVariable Normal
"hi default link LspCxxHlSymParameter Normal
"hi default link LspCxxHlSymField LspCxxHlGroupMemberVariable
"
"" clangd-only groups
"" A static member variable
"hi default link LspCxxHlSymUnknownStaticField Normal
"" Seems to be when a type alias refers to a primitive
"hi default link LspCxxHlSymPrimitive Type
"" Equivalent to TypeAlias
"hi default link LspCxxHlSymTypedef Type
"" Equivalent to TypeParameter
"hi default link LspCxxHlSymTemplateParameter Type
"" Equivalent to EnumMember
"hi default link LspCxxHlSymEnumConstant LspCxxHlGroupEnumConstant
"" A type dependent on a template
"" E.g. T::A, A would be a dependent type
"hi default link LspCxxHlSymDependentType Type
"" A name dependent on a template, usually a function but can also be a variable?
"hi default link LspCxxHlSymDependentName Function
"" C++20 concepts, maybe type is sufficient for now...
"hi default link LspCxxHlSymConcept Type
"
