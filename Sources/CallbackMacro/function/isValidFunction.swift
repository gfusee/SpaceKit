import SwiftSyntax

extension FunctionDeclSyntax {
    func isValidCallbackFunction() throws(CallbackMacroError) {
        let isPublic = self.modifiers
            .contains(where: { $0.name.tokenKind == .keyword(.public)})
        
        guard isPublic else {
            throw CallbackMacroError.shouldBePublic
        }
    }
}

