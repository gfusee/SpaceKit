import SwiftSyntax
import SwiftSyntaxMacros

extension ABIMeta: MemberMacro {
    static public func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw ABIMetaMacroError.onlyApplicableToStruct
        }
        
        try structDecl.isValidStruct()
        
        return [
            try getExtractABIFromSymbolGraphsFunction(
                graphJSONContents: try getContentsArgument(node: node),
                spaceKitGraphJSONContent: try getSpaceKitGraphPathArgument(node: node)
            )
        ]
    }
}

private func getContentsArgument(node: AttributeSyntax) throws(ABIMetaMacroError) -> [String] {
    let contentsArg: ArrayExprSyntax? = if case .argumentList(let args) = node.arguments {
        args.first?.expression.as(ArrayExprSyntax.self)
    } else {
        nil
    }
    
    guard let contentsArrayArg = contentsArg else {
        throw ABIMetaMacroError.noGraphJSONContentsArgumentProvided
    }
    
    let contentsWithNils: [String?] = contentsArrayArg.elements
        .map { $0.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue }
    
    guard !contentsWithNils.contains(nil) else {
        throw ABIMetaMacroError.pathsShouldBeStringLiterals
    }
    
    return contentsWithNils.compactMap { $0 }
}

private func getSpaceKitGraphPathArgument(node: AttributeSyntax) throws(ABIMetaMacroError) -> String {
    let spaceKitGraphContentArg: StringLiteralExprSyntax? = if case .argumentList(let args) = node.arguments {
        args.count >= 1 ? args.suffix(args.count - 1).first?.expression.as(StringLiteralExprSyntax.self) : nil
    } else {
        nil
    }
    
    guard let spaceKitGraphContentValue = spaceKitGraphContentArg?.representedLiteralValue else {
        throw ABIMetaMacroError.noSpaceKitGraphJSONContentArgumentProvided
    }
    
    return spaceKitGraphContentValue
}
