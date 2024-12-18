import SwiftSyntax
import SwiftSyntaxMacros

func generateABITypeExtractorClassForStruct(
    structDecl: StructDeclSyntax,
    context: some MacroExpansionContext
) throws -> DeclSyntax {
    let structName = structDecl.name.trimmed
    let generatedClassName = context.makeUniqueName(structName.text)
    
    return """
    #if !WASM
    class \(generatedClassName): ABITypeExtractor {
        public static var _abiTypeName: String {
            \(structName)._abiTypeName
        }
    
        public static var _extractABIType: ABIType? {
            \(structName)._extractABIType
        }
    }
    #endif
    """
}
