import SwiftSyntax
import SwiftSyntaxMacros

extension Callback: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        if let funcDecl = declaration.as(FunctionDeclSyntax.self) {
            return try generateFuncConformance(funcDecl: funcDecl)
        } else {
            throw CallbackMacroError.onlyApplicableToFunc
        }
    }
}
