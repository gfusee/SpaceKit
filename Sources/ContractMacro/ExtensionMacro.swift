import SwiftSyntax
import SwiftSyntaxMacros

extension Contract: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw ContractMacroError.onlyApplicableToStruct
        }
        
        try structDecl.isValidStruct()
        
        var results: [ExtensionDeclSyntax] = []
        
        // Pre-processor instructions are not allowed in ExtensionDeclSyntax. They work here, even though it's not ideal
        #if !WASM
        let functionDecls = structDecl.memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
        
        let contractEndpointSelectorConformance = try getContractEndpointSelectorConformance(structDecl: structDecl, functions: functionDecls)
        
        results.append(contractEndpointSelectorConformance)
        #endif
        
        return results
    }
}

func getContractEndpointSelectorConformance(
    structDecl: StructDeclSyntax,
    functions: [FunctionDeclSyntax]
) throws -> ExtensionDeclSyntax {
    let structName = structDecl.name.trimmed
    
    for function in functions {
        guard function.isEndpoint() else {
            continue
        }
    }
    
    var extensionSyntax = try ExtensionDeclSyntax(
        "extension \(structName): ContractEndpointSelector"
    ) {
        """
        @inline(__always)
        public mutating func callEndpoint(name: String) {
            switch self {
            default:
                API.throwFunctionNotFoundError()
            }
        }
        """
    }
    
    return extensionSyntax
}
