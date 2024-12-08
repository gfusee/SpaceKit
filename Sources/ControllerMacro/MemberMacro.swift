import SwiftSyntax
import SwiftSyntaxMacros

extension Controller: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw ControllerMacroError.onlyApplicableToStruct
        }
        
        try structDecl.isValidStruct()
        
        let initDecl = InitializerDeclSyntax(
            modifiers: [
                DeclModifierSyntax(name: TokenSyntax.keyword(.public))
            ],
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: []
                )
            ),
            body: CodeBlockSyntax(
                statements: ""
            )
        )
        
        let functionDecls = structDecl.memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
        
        let testableStructDecl = getTestableStructDeclaration(
            structDecl: structDecl,
            functions: functionDecls
        )
        
        let contractInitDecl = getStaticInitializerDeclarations(structDecl: structDecl, initDecl: initDecl)
        
        let testableDeclSyntax = """
        #if !WASM
        \(testableStructDecl.formatted())
        #endif
        """
        
        let contractInitDeclSyntax = """
        #if !WASM
        \(contractInitDecl.formatted())
        #endif
        """
        
        let bundleHelperClass: DeclSyntax = """
        #if !WASM
        public class __BundleHelper {}
        #endif
        """
            
        
        var results: [DeclSyntax] = [
            DeclSyntax(stringLiteral: testableDeclSyntax),
            DeclSyntax(stringLiteral: contractInitDeclSyntax),
            bundleHelperClass
        ]
        
        results.append(contentsOf:
            getStaticEndpointDeclarations(
                structDecl: structDecl,
                functions: functionDecls
            ).map({ DeclSyntax($0) })
        )
        
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

fileprivate func getTestableStructDeclaration(
    structDecl: StructDeclSyntax,
    functions: [FunctionDeclSyntax]
) -> StructDeclSyntax {
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
    
    let transactionInputOptionalParameters: [FunctionParameterSyntax] = [
        "transactionInput: ContractCallTransactionInput? = nil,",
        "transactionOutput: TransactionOutput = TransactionOutput()"
    ]
        .map { FunctionParameterSyntax(stringLiteral: $0) }
    
    let testableStaticInitializerParameters: FunctionParameterListSyntax = ["address: String"]
    
    var parameterNamesList: [String] = []
    var initCallParametersList: [String] = []
    
    for parameter in initDecl.signature.parameterClause.parameters {
        let parameterName = parameter.secondName ?? parameter.firstName
        initCallParametersList.append("\(parameterName): \(parameterName)")
        parameterNamesList.append("\(parameterName)")
    }
    
    let testableInitDecl = InitializerDeclSyntax(
        signature: FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(
                parameters: testableStaticInitializerParameters // Same as the static func testable
            )
        ),
        body: CodeBlockSyntax(
            statements: """
            self.address = address
            """
        )
    )
    
    var memberBlock = MemberBlockSyntax(membersBuilder: {
        "let address: String"
    })
    
    memberBlock.members.append(MemberBlockItemSyntax(decl: testableInitDecl))
    
    for function in functions {
        var function = function
        guard function.isEndpoint() else {
            continue
        }
        
        if function.isCallback() {
            function.attributes = function.attributes.filter { attributes in
                attributes.description.trimmingCharacters(in: .whitespacesAndNewlines) != "@Callback"
            }
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
        
        var testableFunction = function
        
        // We have to add a comma to the last parameter declaration
        let baseParameters = testableFunction.signature.parameterClause.parameters
            .map { parameter in
                var parameter = parameter
                
                parameter.trailingComma = parameter.trailingComma ?? ","
                
                return parameter
            }
        
        var throwsEffectSpecifiers = FunctionEffectSpecifiersSyntax()
        throwsEffectSpecifiers.throwsSpecifier = TokenSyntax.init(stringLiteral: "throws(TransactionError)")
        
        testableFunction.signature.parameterClause.parameters = FunctionParameterListSyntax(baseParameters + transactionInputOptionalParameters)
        testableFunction.signature.effectSpecifiers = throwsEffectSpecifiers
        
        let argsDeclaration = "[\(variableNames)]"
        
        var runTestCallArguments: [String] = [
            "contractAddress: self.address",
            """
            endpointName: "\(function.name.trimmed.description)"
            """,
            """
            transactionInput: transactionInput.toTransactionInput(
                contractAddress: self.address,
                arguments: \(argsDeclaration)
            )
            """,
            "transactionOutput: transactionOutput",
        ]
        
        let returnType = testableFunction.signature.returnClause?.type.trimmed
        
        if let returnType = returnType {
            runTestCallArguments.append("for: \(returnType).self")
        }
        
        if testableFunction.signature.returnClause != nil {
            testableFunction.signature.returnClause?.type = "\(returnType).SwiftVMDecoded"
        } else {
            let type: TypeSyntax = "Void"
            testableFunction.signature.returnClause = ReturnClauseSyntax(type: type)
        }
        
        
        testableFunction.body = CodeBlockSyntax(
            statements: """
            let transactionInput = transactionInput ?? ContractCallTransactionInput()
            return try runTestCall(
                \(raw: runTestCallArguments.joined(separator: ",\n"))
            ) {
                \(structDecl.name.trimmed).\(function.name)()
            }
            """
        )
        
        memberBlock.members.append(MemberBlockItemSyntax(decl: testableFunction))
    }
    
    let testableStruct = StructDeclSyntax(
        modifiers: [
            DeclModifierSyntax.init(name: .keyword(.public))
        ],
        name: "Testable: TestableContract",
        memberBlock: memberBlock
    )
    
    return testableStruct
}

fileprivate func getStaticEndpointDeclarations(
    structDecl: StructDeclSyntax,
    functions: [FunctionDeclSyntax]
) -> [FunctionDeclSyntax] {
    let structName = structDecl.name.trimmed
    var results: [FunctionDeclSyntax] = []
    
    for function in functions {
        guard function.isEndpoint() else {
            continue
        }
        
        let endpointParams = getEndpointVariablesDeclarations(
            isCallback: function.isCallback(),
            functionParameters: function.signature.parameterClause.parameters
        )
        
        let isMutating = function.modifiers.contains(where: { $0.name.tokenKind == .keyword(.mutating) })
        let contractInstantiationKeyword = isMutating ? "var" : "let"
        
        let contractVariableDeclaration: ExprSyntax = "\(raw: contractInstantiationKeyword) _contract = \(structName)()"
        
        let body: String
        if function.signature.returnClause != nil {
            body = """
            \(contractVariableDeclaration)
            \(endpointParams.argumentDeclarations)
            let endpointOutput = _contract.\(function.name)(\(endpointParams.contractFunctionCallArguments))
            
            var outputAdapter = ApiOutputAdapter()
            endpointOutput.multiEncode(output: &outputAdapter)
            """
        } else {
            body = """
            \(contractVariableDeclaration)
            \(endpointParams.argumentDeclarations)
            _contract.\(function.name)(\(endpointParams.contractFunctionCallArguments))
            """
        }
        
        let bodySyntax = CodeBlockSyntax(statements: """
        \(raw: body)
        """)
        
        let staticEndpointSyntax = FunctionDeclSyntax(
            attributes: [
                .attribute("@inline(__always)")
            ],
            modifiers: [
                DeclModifierSyntax.init(name: .keyword(.public)),
                DeclModifierSyntax.init(name: .keyword(.static)),
            ],
            name: function.name,
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: []
                )
            ),
            body: bodySyntax
        )
        
        results.append(staticEndpointSyntax)
    }
    
    return results
}

fileprivate func getStaticInitializerDeclarations(
    structDecl: StructDeclSyntax,
    initDecl: InitializerDeclSyntax
) -> FunctionDeclSyntax {
    let bodySyntax = CodeBlockSyntax(statements: """
    let bundle = Bundle(for: type(of: __BundleHelper()))
    let fullyQualifiedName = String(reflecting: Self.self)
    if let moduleName = fullyQualifiedName.split(separator: ".").first {
        let className = moduleName + "." + "__ContractInit"
        if let classType = bundle.classNamed(className) as? SwiftVMInit.Type {
            _ = classType.init()
        } else {
            // Class not found
        }
    }
    """)
    
    let staticEndpointSyntax = FunctionDeclSyntax(
        attributes: [
            .attribute("@inline(__always)")
        ],
        modifiers: [
            DeclModifierSyntax.init(name: .keyword(.public)),
            DeclModifierSyntax.init(name: .keyword(.static)),
        ],
        name: "__contractInit",
        signature: FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(
                parameters: []
            )
        ),
        body: bodySyntax
    )
    
    return staticEndpointSyntax
}

fileprivate func getEndpointVariablesDeclarations(
    isCallback: Bool,
    functionParameters: FunctionParameterListSyntax
) -> (argumentDeclarations: String, contractFunctionCallArguments: String) {
    var contractFunctionCallArgumentsList: [String] = []
    var argumentDeclarationsList: [String] = []
    
    for parameter in functionParameters {
        let variableName = parameter.secondName ?? parameter.firstName
        let variableType = parameter.type
        
        argumentDeclarationsList.append("let \(variableName) = \(variableType)(topDecodeMulti: &_argsLoader)")
        
        if parameter.firstName == "_" {
            contractFunctionCallArgumentsList.append("\(variableName)")
        } else {
            contractFunctionCallArgumentsList.append("\(parameter.firstName): \(variableName)")
        }
    }
    
    var loaderDeclaration: String?
    if isCallback {
        if argumentDeclarationsList.isEmpty {
            // TODO: add tests for this, if a callback is not properly protected it would lead to desastrous consequences
            loaderDeclaration = "let _ = CallbackClosureLoader()" // We need this so the exported function fails in case of direct (non-callback) call
        } else {
            loaderDeclaration = "var _argsLoader = CallbackClosureLoader()"
        }
    } else if !argumentDeclarationsList.isEmpty {
        loaderDeclaration = "var _argsLoader = EndpointArgumentsLoader()"
    }
    
    if let loaderDeclaration = loaderDeclaration {
        // We have to add the loader declaration at the start of the argumentDeclarationsList array
        argumentDeclarationsList.insert(loaderDeclaration, at: 0)
    }
    
    let argumentDeclarations = argumentDeclarationsList.joined(separator: "\n")
    let contractFunctionCallArguments = contractFunctionCallArgumentsList.joined(separator: ", ")
    
    return (
        argumentDeclarations: argumentDeclarations,
        contractFunctionCallArguments: contractFunctionCallArguments
    )
}
