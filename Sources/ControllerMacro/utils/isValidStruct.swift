import SwiftSyntax

extension StructDeclSyntax {
    func isValidStruct() throws(ControllerMacroError) {
        guard self.modifiers.contains(where: { $0.name.tokenKind == .keyword(.public) }) else {
            throw ControllerMacroError.shouldBePublic
        }
        
        let members = self.memberBlock.members
        
        guard members.filter({ $0.decl.is(InitializerDeclSyntax.self) }).isEmpty else {
            throw ControllerMacroError.noInitAllowed
        }
        
        // TODO: ensure no static method are presents
    }
}
