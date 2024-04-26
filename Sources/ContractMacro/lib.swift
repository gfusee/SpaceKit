import SwiftSyntax
import SwiftSyntaxMacros
import SwiftCompilerPlugin

public struct Contract: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw ContractMacroError.onlyApplicableToStruct
        }
        
        let members = structDecl.memberBlock.members
        
        guard members.filter({ $0.decl.is(InitializerDeclSyntax.self) }).count < 2 else {
            throw ContractMacroError.onlyOneConvenienceInitAllowed
        }
        
        let hasClassicInit = members.contains { member in
            guard let initDecl = member.decl.as(InitializerDeclSyntax.self) else {
                return false
            }
            
            if initDecl.modifiers.contains(where: { $0.name.tokenKind == .keyword(.convenience) }) {
                return false
            }
            
            return true
        }
        
        guard !hasClassicInit else {
            throw ContractMacroError.onlyOneConvenienceInitAllowed
        }
        
        let optionalConvenienceInitDecl = members.first (where: { member in
            guard let initDecl = member.decl.as(InitializerDeclSyntax.self) else {
                return false
            }
            
            return initDecl.modifiers.contains(where: { $0.name.tokenKind == .keyword(.convenience) })
        })
        
        let initDecl = optionalConvenienceInitDecl?.decl.as(InitializerDeclSyntax.self) ?? InitializerDeclSyntax(
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
            getInitExportDeclaration(structName: structDecl.name, init: initDecl, context: context)
        ]
        
        let functionDecls = members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
        for function in functionDecls {
            if let decl = getEndpointExportDeclaration(structName: structDecl.name, function: function, context: context) {
                results.append(decl)
            }
        }
        
        return results.map { DeclSyntax($0) }
    }
}

func getEndpointExportDeclaration(structName: TokenSyntax, function: FunctionDeclSyntax, context: some MacroExpansionContext) -> FunctionDeclSyntax? {
    guard function.modifiers.contains(where: { $0.name.tokenKind == .keyword(.public)}) else {
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
    
    let body: CodeBlockSyntax
    if function.signature.returnClause != nil {
        body = CodeBlockSyntax(statements: """
        var result = MXBuffer()
        let endpointOutput = \(structName.trimmed)().\(function.name)()
        endpointOutput.topEncode(output: &result)
        
        result.finish()
        """)
    } else {
        body = CodeBlockSyntax(statements: """
        \(structName.trimmed)().\(function.name)()
        """)
    }
    
    exportedFunction.body = body
    
    return exportedFunction
}

func getInitExportDeclaration(structName: TokenSyntax, init: InitializerDeclSyntax, context: some MacroExpansionContext) -> FunctionDeclSyntax {
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
    
    exportedFunction.body = CodeBlockSyntax(statements: """
    let _ = \(structName.trimmed).init()
    """)
    
    return exportedFunction
}

@main
struct ContractMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Contract.self,
    ]
}
