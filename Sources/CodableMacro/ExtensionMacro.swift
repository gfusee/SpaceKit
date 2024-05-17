import SwiftSyntax
import SwiftSyntaxMacros

extension Codable: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            return try generateStructConformance(structDecl: structDecl)
        } else {
            throw CodableMacroError.onlyApplicableToStructOrEnum
        }
    }
}
