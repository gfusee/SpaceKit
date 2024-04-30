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
        
        let optionalInitDecl = structDecl.memberBlock.members.first(where: { member in
            guard let initDecl = member.decl.as(InitializerDeclSyntax.self) else {
                return false
            }
            
            return true
        })
        
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
    
    let contractVariableDeclaration: ExprSyntax = "var contract = \(structName.trimmed)(_noDeploy: ())"
    
    let body: String
    if function.signature.returnClause != nil {
        body = """
        var result = MXBuffer()
        
        \(contractVariableDeclaration)
        let endpointOutput = contract.\(function.name)()
        
        endpointOutput.topEncode(output: &result)
        
        result.finish()
        """
    } else {
        body = """
        \(contractVariableDeclaration)
        contract.\(function.name)(\(endpointParams.contractFunctionCallArguments))
        """
    }
    
    exportedFunction.body = CodeBlockSyntax(statements: """
    withTransactionArguments { (\(raw: endpointParams.withTransactionArgumentsParams)) in
        \(raw: body)
    }
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
    withTransactionArguments { (\(raw: endpointParams.withTransactionArgumentsParams)) in
        let _ = \(structName.trimmed)(\(raw: endpointParams.contractFunctionCallArguments))
    }
    """)
    
    return exportedFunction
}

fileprivate func getEndpointVariablesDeclarations(
    functionParameters: FunctionParameterListSyntax
) -> (withTransactionArgumentsParams: String, contractFunctionCallArguments: String) {
    var withTransactionArgumentsParamList: [String] = []
    var contractFunctionCallArgumentsList: [String] = []
    
    for parameter in functionParameters {
        let variableName = parameter.secondName ?? parameter.firstName
        withTransactionArgumentsParamList.append("\(variableName): \(parameter.type)")
        contractFunctionCallArgumentsList.append("\(variableName): \(variableName)")
    }
    
    let withTransactionArgumentsParams = withTransactionArgumentsParamList.joined(separator: ", ")
    let contractFunctionCallArguments = contractFunctionCallArgumentsList.joined(separator: ", ")
    
    return (
        withTransactionArgumentsParams: withTransactionArgumentsParams,
        contractFunctionCallArguments: contractFunctionCallArguments
    )
}
