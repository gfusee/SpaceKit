import SwiftSyntax
import SwiftSyntaxMacros

extension Contract: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw ContractMacroError.onlyApplicableToStruct
        }
        
        try structDecl.isValidStruct()
        
        var results: [FunctionDeclSyntax] = [
            getInitExportDeclaration(structName: structDecl.name, context: context)
        ]
        
        let functionDecls = structDecl.memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
        for function in functionDecls {
            if let decl = getEndpointExportDeclaration(structName: structDecl.name, function: function, context: context) {
                results.append(decl)
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

fileprivate func getInitExportDeclaration(structName: TokenSyntax, context: some MacroExpansionContext) -> FunctionDeclSyntax {
    var exportedFunction = FunctionDeclSyntax(
        name: context.makeUniqueName("init"),
        signature: FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(
                parameters: []
            )
        )
    )
    
    exportedFunction.attributes = """
    #if WASM
    @_expose(wasm, "init")
    @_cdecl("init")
    #endif
    """
    
    exportedFunction.body = CodeBlockSyntax(statements: """
        \(structName).__contractInit()
    """)
    
    return exportedFunction
}
