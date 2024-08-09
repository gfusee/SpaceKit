import SwiftSyntax
import SwiftSyntaxMacros

extension FunctionDeclSyntax {
    package func isCallback() -> Bool {
        guard self.isEndpoint() else {
            return false
        }
        
        // TODO: this is a CRITICAL function, add tests with the WASM VM
        self.attributes.contains { item in
            return item.description.trimmingCharacters(in: .whitespacesAndNewlines) == "@Callback"
        }
    }
}
