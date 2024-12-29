import SwiftSyntax

extension StructDeclSyntax {
    func isValidStruct() throws(ABIMetaMacroError) {
        let members = self.memberBlock.members
        
        guard members.isEmpty else {
            throw ABIMetaMacroError.noMemberAllowed
        }
        
        // TODO: ensure no static method are presents
    }
}
