import SwiftSyntax
import SwiftSyntaxMacros

extension Init: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let funcDecl: FunctionDeclSyntax = declaration.as(FunctionDeclSyntax.self) else {
            throw InitMacroError.onlyApplicableToAFunction
        }
        
        guard funcDecl.name.trimmed.description == "initialize" else {
            throw InitMacroError.functionNameMustBeInitialize
        }
        
        return [
            DeclSyntax(getInitExportDeclarations(funcDecl: funcDecl, context: context))
        ]
    }
}

fileprivate func getInitExportDeclarations(funcDecl: FunctionDeclSyntax, context: some MacroExpansionContext) -> FunctionDeclSyntax {
    let endpointParams = getInitVariablesDeclarations(
        functionParameters: funcDecl.signature.parameterClause.parameters
    )
    
    let bodySyntax = CodeBlockSyntax(statements: """
    \(raw: endpointParams)
    \(funcDecl.body?.statements ?? [])
    """)
    
    var exportedFunction = FunctionDeclSyntax(
        name: context.makeUniqueName("init"),
        signature: FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(
                parameters: []
            )
        ),
        body: bodySyntax
    )
    
    exportedFunction.attributes = """
    #if WASM
    @_expose(wasm, "init")
    @_cdecl("init")
    #else
    @_silgen_name("__swiftVMInitialize")
    #endif
    """
    
    return exportedFunction
}

fileprivate func getInitVariablesDeclarations(
    functionParameters: FunctionParameterListSyntax
) -> String {
    var argumentDeclarationsList: [String] = []
    
    for parameter in functionParameters {
        let variableName = parameter.secondName ?? parameter.firstName
        let variableType = parameter.type
        
        argumentDeclarationsList.append("let \(variableName) = \(variableType)(topDecodeMulti: &_argsLoader)")
    }
    
    let loaderDeclaration: String? = if !argumentDeclarationsList.isEmpty {
        "var _argsLoader = EndpointArgumentsLoader()"
    } else {
        nil
    }
    
    if let loaderDeclaration = loaderDeclaration {
        // We have to add the loader declaration at the start of the argumentDeclarationsList array
        argumentDeclarationsList.insert(loaderDeclaration, at: 0)
    }
    
    let argumentDeclarations = argumentDeclarationsList.joined(separator: "\n")
    
    return argumentDeclarations
}
