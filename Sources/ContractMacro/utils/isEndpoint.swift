import SwiftSyntax
import SwiftSyntaxMacros

extension FunctionDeclSyntax {
    package func isEndpoint() -> Bool {
        self.modifiers.contains(where: { $0.name.tokenKind == .keyword(.public)})
    }
}
