import SwiftSyntax
import SwiftSyntaxMacros

extension Controller: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw ControllerMacroError.onlyApplicableToStruct
        }
        
        try structDecl.isValidStruct()
        
        var results: [DeclSyntax] = [
            try generateABIEndpointsExtractorClass(structDecl: structDecl, context: context)
        ]
        
        let functionDecls = structDecl.memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
        for function in functionDecls {
            guard !function.attributes.contains(where: { $0.description.trimmingCharacters(in: .whitespacesAndNewlines) == "@Init" }) else {
                throw ControllerMacroError.initAnnotatedFunctionShouldBeGlobal
            }
            
            if let decl = getEndpointExportDeclaration(structName: structDecl.name, function: function, context: context) {
                results.append(DeclSyntax(decl))
            }
        }
        
        return results.map { DeclSyntax($0) }
    }
}

fileprivate func getEndpointExportDeclaration(structName: TokenSyntax, function: FunctionDeclSyntax, context: some MacroExpansionContext) -> FunctionDeclSyntax? {
    guard function.isEndpoint() else {
        return nil
    }
    
    let endpointName = function.name.trimmed
    
    var exportedFunction = FunctionDeclSyntax(
        name: context.makeUniqueName(function.name.text),
        signature: FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(
                parameters: []
            )
        )
    )
    
    exportedFunction.attributes = """
    #if WASM
    @_expose(wasm, "\(endpointName)")
    @_cdecl("\(endpointName)")
    #endif
    """
    
    exportedFunction.body = CodeBlockSyntax(
        statements: """
        \(structName).\(endpointName)()
        """
    )
    
    return exportedFunction
}
