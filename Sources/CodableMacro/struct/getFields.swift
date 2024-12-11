import SwiftSyntax

public extension StructDeclSyntax {
    func getFields() -> [VariableDeclSyntax] {
        self.memberBlock.members.compactMap { member in
            
            guard var field = member.decl.as(VariableDeclSyntax.self) else {
                return nil
            }
            
            field.trailingTrivia = Trivia(pieces: [])
            
            return field
        }
    }
}
