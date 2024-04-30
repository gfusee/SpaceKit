import SwiftSyntax

extension StructDeclSyntax {
    func isValidStruct() throws(ContractMacroError) {
        let members = self.memberBlock.members
        
        guard members.filter({ $0.decl.is(InitializerDeclSyntax.self) }).count < 2 else {
            throw ContractMacroError.onlyOneInitAllowed
        }
    }
}
