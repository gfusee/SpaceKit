import SwiftSyntax

extension StructDeclSyntax {
    func hasClassicInit() -> Bool {
        self.memberBlock.members.contains { member in
            guard let initDecl = member.decl.as(InitializerDeclSyntax.self) else {
                return false
            }
            
            return true
        }
    }
}
