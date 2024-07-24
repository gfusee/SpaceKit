import SwiftSyntax
import SwiftSyntaxMacros

extension FunctionDeclSyntax {
    package func isEndpoint() -> Bool {
        // TODO: this is a CRITICAL function, add tests with the WASM VM
        self.modifiers.contains(where: { $0.name.tokenKind == .keyword(.public)})
    }
}
