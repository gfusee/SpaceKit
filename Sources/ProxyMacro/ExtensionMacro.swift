import SwiftSyntax
import SwiftSyntaxMacros

extension Proxy: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            return try generateEnumExtension(enumDecl: enumDecl)
        } else {
            throw ProxyMacroError.onlyApplicableToEnum
        }
    }
}
