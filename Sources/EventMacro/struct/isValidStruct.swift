import SwiftSyntax

extension StructDeclSyntax {
    func isValidStruct() throws(EventMacroError) {
        guard self.modifiers.contains(where: { $0.name.tokenKind == .keyword(.public) }) else {
            throw EventMacroError.shouldBePublic
        }
        
        let members = self.memberBlock.members
        
        guard members.filter({ $0.decl.is(InitializerDeclSyntax.self) }).isEmpty else {
            throw EventMacroError.noInitAllowed
        }
    }
}
