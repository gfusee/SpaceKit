import SwiftSyntax
import SwiftSyntaxMacros

extension Event: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let arg: LabeledExprSyntax? = if case .argumentList(let args) = node.arguments {
            args.first
        } else {
            nil
        }
        
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            return try generateStructExtension(
                structDecl: structDecl,
                dataTypeName: arg?.expression.description
            )
        } else {
            throw EventMacroError.onlyApplicableToStruct
        }
    }
}
