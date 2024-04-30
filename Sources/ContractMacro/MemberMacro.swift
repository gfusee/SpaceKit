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
    var memberBlock = MemberBlockSyntax(membersBuilder: {
        "let address: String"
    })
    
    for function in functions {
        guard function.isEndpoint() else {
            continue
        }
        
        var argsList: [String] = []
        for parameter in function.signature.parameterClause.parameters {
            let paramName = parameter.firstName == "_" ? "" : "\(parameter.firstName):"
            let variableName = parameter.secondName ?? parameter.firstName
            argsList.append("\(paramName) \(variableName)")
        }
        let args = argsList.joined(separator: ", ")
        
        var testableFunction = function
        testableFunction.body = CodeBlockSyntax(
            statements: """
            return runTestCall(
                contractAddress: self.address,
                endpointName: "\(function.name)",
                hexEncodedArgs: []
            ) {
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
    
    var testableAddressParameter = "_ _testableAddress: String"
    if initDecl.signature.parameterClause.parameters.count > 0 {
        testableAddressParameter += ", "
    }
    
    let testableStaticInitializerParameters = [FunctionParameterSyntax(stringLiteral: testableAddressParameter)] + initDecl.signature.parameterClause.parameters
    
    let testableStaticInitializer: FunctionDeclSyntax = FunctionDeclSyntax.init(
        modifiers: [
            DeclModifierSyntax.init(name: .keyword(.public)),
            DeclModifierSyntax.init(name: .keyword(.static))
        ],
        name: "testable",
        signature: FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(
                parameters: testableStaticInitializerParameters
            ),
            returnClause: ReturnClauseSyntax(
                type: TypeSyntax(stringLiteral: "Testable")
            )
        ),
        bodyBuilder: {
            "Testable(address: _testableAddress)"
        }
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
