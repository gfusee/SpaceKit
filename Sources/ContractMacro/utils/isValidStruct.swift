import SwiftSyntax

extension StructDeclSyntax {
    func isValidStruct() throws(ContractMacroError) {
        let members = self.memberBlock.members
        
        guard members.filter({ $0.decl.is(InitializerDeclSyntax.self) }).isEmpty else {
            throw ContractMacroError.noInitAllowed
        }
        
        // TODO: ensure no static method are presents
    }
}
