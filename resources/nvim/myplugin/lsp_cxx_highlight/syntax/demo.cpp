#include <iostream>

#define LspCxxHlMacro 
//LspCxxHlComment
/*LspCxxHlComment*/
int LspCxxHlSymFunction(int LspCxxHlSymParameter)
{
	static int LspCxxHlSymFunctionVariableStatic = 0;
	int LspCxxHlSymVariable = LspCxxHlSymFunctionVariableStatic;
	return LspCxxHlSymParameter + LspCxxHlSymVariable;
}
enum LspCxxHlSymEnum { LspCxxHlSymEnumMember };
struct LspCxxHlSymStruct
{
	int LspCxxHlSymField;
	void LspCxxHlSymMethod();
};
template <class LspCxxHlSymTypeParameter>
class LspCxxHlSymClass
{
	public:
	private:
	protected:
	LspCxxHlSymClass();
	~LspCxxHlSymClass();
	static int LspCxxHlSymStaticMethod() {
		static int LspCxxHlSymStaticMethodVariableStatic = 0;
		goto LspCxxHlUserLabel;
	LspCxxHlUserLabel:
		return "LspCxxHlLiterals"[LspCxxHlSymStaticMethodVariableStatic];
	}
	static int LspCxxHlSymField;
};
template <class LspCxxHlSymTypeParameter>
int LspCxxHlSymClass<LspCxxHlSymTypeParameter>::LspCxxHlSymField = 0;
static int LspCxxHlSymFileVariableStatic = 0;
int LspCxxHlSymFileVariable = LspCxxHlSymFileVariableStatic;
using spCxxHlSymTypeAlias = int;
typedef int LspCxxHlSymTypeAlias;
namespace LspCxxHlSymNamespace {
	static int LspCxxHlSymNamespaceVariableStatic = 0;
	int LspCxxHlSymNamespaceVariable = LspCxxHlSymNamespaceVariableStatic;
}

int main(int argc, char* argv[]) {
	std::cout << "Hello World!" << std::endl;
}
