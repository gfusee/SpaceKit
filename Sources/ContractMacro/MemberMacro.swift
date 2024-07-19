import SwiftSyntax
import SwiftSyntaxMacros

extension Contract: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw ContractMacroError.onlyApplicableToStruct
        }
        
        try structDecl.isValidStruct()
        
        let functionDecls = structDecl.memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
        
        let testableStructDecl = getTestableStructDeclaration(
            structDecl: structDecl,
            functions: functionDecls
        )
        
        let testableDeclSyntax = """
        #if !WASM
        \(testableStructDecl.staticInitializer.formatted())
        
        \(testableStructDecl.struct.formatted())
        #endif
        """
        
        var results: [DeclSyntax] = [
            DeclSyntax(getNoDeployInit()),
            DeclSyntax(stringLiteral: testableDeclSyntax)
        ]
        
        if !structDecl.hasClassicInit() {
            results.insert(
                DeclSyntax(
                    InitializerDeclSyntax(
                        signature: FunctionSignatureSyntax(
                            parameterClause: FunctionParameterClauseSyntax(
                                parameters: []
                            )
                        ),
                        body: CodeBlockSyntax(
                            statements: ""
                        )
                    )
                ),
                at: 0
            )
        }
        
        return results
    }
}

func getTestableStructDeclaration(
    structDecl: StructDeclSyntax,
    functions: [FunctionDeclSyntax]
) -> (staticInitializer: FunctionDeclSyntax, struct: StructDeclSyntax) {
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
    
    let testableAddressParameter = "_ _testableAddress: String,"
    
    // We have to add a comma to the last parameter declaration
    let initEndpointParameters = initDecl.signature.parameterClause.parameters
        .map { parameter in
            var parameter = parameter
            
            parameter.trailingComma = parameter.trailingComma ?? ","
            
            return parameter
        }
    
    let transactionInputOptionalParameters: [FunctionParameterSyntax] = [
        "callerAddress: String? = nil,",
        "egldValue: BigUint = 0,",
        "esdtValue: MXArray<TokenPayment> = [],",
        "transactionOutput: TransactionOutput = TransactionOutput()"
    ]
        .map { FunctionParameterSyntax(stringLiteral: $0) }
    
    let testableStaticInitializerParameters: FunctionParameterListSyntax = [FunctionParameterSyntax(stringLiteral: testableAddressParameter)] + initEndpointParameters + transactionInputOptionalParameters
    
    var parameterNamesList: [String] = []
    var initCallParametersList: [String] = []
    
    for parameter in initDecl.signature.parameterClause.parameters {
        let parameterName = parameter.secondName ?? parameter.firstName
        initCallParametersList.append("\(parameterName): \(parameterName)")
        parameterNamesList.append("\(parameterName)")
    }
    
    let initCallParameters = initCallParametersList.joined(separator: ", ")
    let parameterNames = parameterNamesList.joined(separator: ", ")
    
    let closureParameterInstantiations = if parameterNames.isEmpty {
        ""
    } else {
        "\(parameterNames) in"
    }
    
    let testableStaticInitializerCallParameters = initCallParameters.count > 0 ? "\(initCallParameters)," : ""
    
    var throwsEffectSpecifiers = FunctionEffectSpecifiersSyntax()
    throwsEffectSpecifiers.throwsSpecifier = TokenSyntax.init(stringLiteral: "throws(TransactionError)")
    
    let testableStaticInitializer: FunctionDeclSyntax = FunctionDeclSyntax.init(
        modifiers: [
            DeclModifierSyntax.init(name: .keyword(.public)),
            DeclModifierSyntax.init(name: .keyword(.static)),
        ],
        name: "testable",
        signature: FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(
                parameters: testableStaticInitializerParameters
            ),
            effectSpecifiers: throwsEffectSpecifiers,
            returnClause: ReturnClauseSyntax(
                type: TypeSyntax(stringLiteral: "Testable")
            )
        ),
        bodyBuilder: {
            "try Testable(_testableAddress, \(raw: testableStaticInitializerCallParameters) callerAddress: callerAddress, egldValue: egldValue, esdtValue: esdtValue, transactionOutput: transactionOutput)"
        }
    )
    
    let testableInitDecl = InitializerDeclSyntax(
        signature: FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(
                parameters: testableStaticInitializerParameters // Same as the static func testable
            ),
            effectSpecifiers: throwsEffectSpecifiers
        ),
        body: CodeBlockSyntax(
            statements: """
            self.address = _testableAddress
            try runTestCall(
                contractAddress: self.address,
                endpointName: "init",
                args: (\(raw: parameterNames)),
                callerAddress: callerAddress,
                egldValue: egldValue,
                esdtValue: esdtValue,
                transactionOutput: transactionOutput
            ) { \(raw: closureParameterInstantiations)
                let ownerAddress = callerAddress?.toAddressData() ?? _testableAddress.toAddressData()
                API.setCurrentSCOwnerAddress(owner: ownerAddress)
                
                let _ = \(structDecl.name.trimmed)(\(raw: initCallParameters))
            }
            """
        )
    )
    
    var memberBlock = MemberBlockSyntax(membersBuilder: {
        "let address: String"
    })
    
    memberBlock.members.append(MemberBlockItemSyntax(decl: testableInitDecl))
    
    for function in functions {
        guard function.isEndpoint() else {
            continue
        }
        
        var variableNamesList: [String] = []
        var argsList: [String] = []
        for parameter in function.signature.parameterClause.parameters {
            let paramName = parameter.firstName == "_" ? "" : "\(parameter.firstName):"
            let variableName = parameter.secondName ?? parameter.firstName
            argsList.append("\(paramName) \(variableName)")
            variableNamesList.append("\(variableName)")
        }
        let variableNames = variableNamesList.joined(separator: ", ")
        let args = argsList.joined(separator: ", ")
        
        let closureVariableInstantiations = if variableNames.isEmpty {
            ""
        } else {
            "\(variableNames) in"
        }
        
        var testableFunction = function
        
        // We have to add a comma to the last parameter declaration
        let baseParameters = testableFunction.signature.parameterClause.parameters
            .map { parameter in
                var parameter = parameter
                
                parameter.trailingComma = parameter.trailingComma ?? ","
                
                return parameter
            }
        
        testableFunction.signature.parameterClause.parameters = FunctionParameterListSyntax(baseParameters + transactionInputOptionalParameters)
        testableFunction.signature.effectSpecifiers = throwsEffectSpecifiers
        
        testableFunction.body = CodeBlockSyntax(
            statements: """
            return try runTestCall(
                contractAddress: self.address,
                endpointName: "\(function.name)",
                args: (\(raw: variableNames)),
                callerAddress: callerAddress,
                egldValue: egldValue,
                esdtValue: esdtValue,
                transactionOutput: transactionOutput
            ) { \(raw: closureVariableInstantiations)
                var contract = \(structDecl.name.trimmed)(_noDeploy: ())
                return contract.\(function.name)(\(raw: args))
            }
            """
        )
        
        memberBlock.members.append(MemberBlockItemSyntax(decl: testableFunction))
    }
    
    let testableStruct = StructDeclSyntax(
        modifiers: [
            DeclModifierSyntax.init(name: .keyword(.public))
        ],
        name: "Testable",
        memberBlock: memberBlock
    )
    
    return (staticInitializer: testableStaticInitializer, struct: testableStruct)
}

func getNoDeployInit() -> InitializerDeclSyntax {
    return InitializerDeclSyntax(
        signature: FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(
                parameters: [
                    "_noDeploy: ()"
                ]
            )
        ),
        body: CodeBlockSyntax(
            statements: ""
        )
    )
}
