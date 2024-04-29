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
        
        let functionDecls = structDecl.memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
        
        let testableStructDecl = getTestableStructDeclaration(
            structName: structDecl.name,
            functions: functionDecls
        )
        
        let testableDeclSyntax = """
        #if !WASM
        \(testableStructDecl.staticInitializer.formatted())
        
        \(testableStructDecl.struct.formatted())
        #endif
        """
        
        return [
            DeclSyntax(stringLiteral: testableDeclSyntax)
        ]
    }
}

func getTestableStructDeclaration(
    structName: TokenSyntax,
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
                return \(structName).init().\(function.name)(\(raw: args))
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
    
    let testableStaticInitializer: FunctionDeclSyntax = FunctionDeclSyntax.init(
        modifiers: [
            DeclModifierSyntax.init(name: .keyword(.public)),
            DeclModifierSyntax.init(name: .keyword(.static))
        ],
        name: "testable",
        signature: FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(
                parameters: [
                    "address: String"
                ]
            ),
            returnClause: ReturnClauseSyntax(
                type: TypeSyntax(stringLiteral: "Testable")
            )
        ),
        bodyBuilder: {
            "Testable(address: address)"
        }
    )
    
    return (staticInitializer: testableStaticInitializer, struct: testableStruct)
}
