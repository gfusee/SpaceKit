import SwiftSyntax

extension StructDeclSyntax {
    func isValidStruct() throws(EventMacroError) {
        let members = self.memberBlock.members
        
        guard members.filter({ $0.decl.is(InitializerDeclSyntax.self) }).isEmpty else {
            throw EventMacroError.noInitAllowed
        }
    }
}
