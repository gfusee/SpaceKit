import SwiftSyntax

extension StructDeclSyntax {
    func hasClassicInit() -> Bool {
        self.memberBlock.members.contains { member in
            guard member.decl.as(InitializerDeclSyntax.self) != nil else {
                return false
            }
            
            return true
        }
    }
}
