import SwiftSyntax
import SwiftSyntaxMacros

extension Event: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw EventMacroError.onlyApplicableToStruct
        }
        
        return [
            try generateABIEventExtractorClass(structDecl: structDecl, context: context)
        ]
    }
}
