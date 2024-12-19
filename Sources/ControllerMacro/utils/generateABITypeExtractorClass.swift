import SwiftSyntax
import SwiftSyntaxMacros

func generateABIEndpointsExtractorClass(
    structDecl: StructDeclSyntax,
    context: some MacroExpansionContext
) throws -> DeclSyntax {
    let structName = structDecl.name.trimmed
    let generatedClassName = context.makeUniqueName(structName.text)
    
    return """
    #if !WASM
    class \(generatedClassName): ABIEndpointsExtractor {
        static var _extractABIEndpoints: [ABIEndpoint] {
            \(structName)._extractABIEndpoints
        }
    }
    #endif
    """
}
