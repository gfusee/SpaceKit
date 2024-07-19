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
        guard case .argumentList(let args) = node.arguments,
              let arg = args.first
        else {
            fatalError() // TODO: add concrete error
        }
        
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            return try generateStructConformance(
                structDecl: structDecl,
                dataTypeName: arg.expression.description
            )
        } else {
            throw EventMacroError.onlyApplicableToStruct
        }
    }
}
