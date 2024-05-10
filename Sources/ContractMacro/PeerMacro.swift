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
        
        let optionalInitDecl = structDecl.memberBlock.members.first(where: { $0.decl.as(InitializerDeclSyntax.self) != nil } )
        
        let initDecl = optionalInitDecl?.decl.as(InitializerDeclSyntax.self) ?? InitializerDeclSyntax(
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: []
                )
            ),
            body: CodeBlockSyntax(
                statements: ""
            )
        )
        
        var results: [FunctionDeclSyntax] = [
            getInitExportDeclaration(structName: structDecl.name, initDecl: initDecl, context: context)
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
    
    var exportedFunction = FunctionDeclSyntax(
        name: context.makeUniqueName(function.name.text),
        signature: FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(
                parameters: []
            )
        )
    )
    
    exportedFunction.attributes = """
    @_expose(wasm, "\(function.name)")
    @_cdecl("\(function.name)")
    """
    
    let endpointParams = getEndpointVariablesDeclarations(
        functionParameters: function.signature.parameterClause.parameters
    )
    
    let contractVariableDeclaration: ExprSyntax = "var _contract = \(structName.trimmed)(_noDeploy: ())"
    
    let body: String
    if function.signature.returnClause != nil {
        body = """
        \(contractVariableDeclaration)
        \(endpointParams.argumentDeclarations)
        let endpointOutput = _contract.\(function.name)(\(endpointParams.contractFunctionCallArguments))
        
        var _result = MXBuffer()
        endpointOutput.topEncode(output: &_result)
        
        _result.finish()
        """
    } else {
        body = """
        \(contractVariableDeclaration)
        \(endpointParams.argumentDeclarations)
        _contract.\(function.name)(\(endpointParams.contractFunctionCallArguments))
        """
    }
    
    exportedFunction.body = CodeBlockSyntax(statements: """
    \(raw: body)
    """)
    
    return exportedFunction
}

fileprivate func getInitExportDeclaration(structName: TokenSyntax, initDecl: InitializerDeclSyntax, context: some MacroExpansionContext) -> FunctionDeclSyntax {
    var exportedFunction = FunctionDeclSyntax(
        name: context.makeUniqueName("init"),
        signature: FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(
                parameters: []
            )
        )
    )
    
    exportedFunction.attributes = """
    @_expose(wasm, "init")
    @_cdecl("init")
    """
    
    let endpointParams = getEndpointVariablesDeclarations(
        functionParameters: initDecl.signature.parameterClause.parameters
    )
    
    exportedFunction.body = CodeBlockSyntax(statements: """
    \(raw: endpointParams.argumentDeclarations)
    let _ = \(structName.trimmed)(\(raw: endpointParams.contractFunctionCallArguments))
    """)
    
    return exportedFunction
}

fileprivate func getEndpointVariablesDeclarations(
    functionParameters: FunctionParameterListSyntax
) -> (argumentDeclarations: String, contractFunctionCallArguments: String) {
    var contractFunctionCallArgumentsList: [String] = []
    var argumentDeclarationsList: [String] = []
    
    for parameter in functionParameters {
        let variableName = parameter.secondName ?? parameter.firstName
        let variableType = parameter.type
        
        if argumentDeclarationsList.isEmpty {
            argumentDeclarationsList.append("var _argsLoader = EndpointArgumentsLoader()")
        }
        
        argumentDeclarationsList.append("let \(variableName) = \(variableType).topDecodeMulti(input: &_argsLoader)")
        contractFunctionCallArgumentsList.append("\(variableName): \(variableName)")
    }
    
    let argumentDeclarations = argumentDeclarationsList.joined(separator: "\n")
    let contractFunctionCallArguments = contractFunctionCallArgumentsList.joined(separator: ", ")
    
    return (
        argumentDeclarations: argumentDeclarations,
        contractFunctionCallArguments: contractFunctionCallArguments
    )
}
