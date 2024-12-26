import SwiftSyntax
import SwiftSyntaxMacros

func generateABITypeExtractorClassForEnum(
    enumDecl: EnumDeclSyntax,
    context: some MacroExpansionContext
) throws -> DeclSyntax {
    let enumName = enumDecl.name.trimmed
    let generatedClassName = context.makeUniqueName(enumName.text)
    
    return """
    #if !WASM
    public class \(generatedClassName): ABITypeExtractor {
        public static var _abiTypeName: String {
            \(enumName)._abiTypeName
        }
    
        public static var _extractABIType: ABIType? {
            \(enumName)._extractABIType
        }
    }
    #endif
    """
}
