import SwiftSyntax
import SwiftSyntaxMacros

extension Codable: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            return [
                try generateABITypeExtractorClassForStruct(
                    structDecl: structDecl,
                    context: context
                )
            ]
        } else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            return [
                try generateABITypeExtractorClassForEnum(
                    enumDecl: enumDecl,
                    context: context
                )
            ]
        } else {
            throw CodableMacroError.onlyApplicableToStructOrEnum
        }
    }
}
