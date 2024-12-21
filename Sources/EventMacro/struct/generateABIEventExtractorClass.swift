import SwiftSyntax
import SwiftSyntaxMacros

func generateABIEventExtractorClass(
    structDecl: StructDeclSyntax,
    context: some MacroExpansionContext
) throws -> DeclSyntax {
    let structName = structDecl.name.trimmed
    let generatedClassName = context.makeUniqueName(structName.text)
    
    return """
    #if !WASM
    class \(generatedClassName): ABIEventExtractor {
        public static var _extractABIEvent: ABIEvent {
            \(structName)._extractABIEvent
        }
    }
    #endif
    """
}
