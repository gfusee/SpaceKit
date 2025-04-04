import SwiftSyntax

extension StructDeclSyntax {
    func isValidStruct() throws(CodableMacroError) {
        guard self.modifiers.contains(where: { $0.name.tokenKind == .keyword(.public) }) else {
            throw CodableMacroError.shouldBePublic
        }
        
        guard self.genericParameterClause == nil else {
            throw CodableMacroError.shouldNotHaveGenericParameter
        }
        
        let members = self.memberBlock.members
        
        guard members.filter({ $0.decl.is(InitializerDeclSyntax.self) }).isEmpty else {
            throw CodableMacroError.noInitAllowed
        }
        
        guard !members.filter({ $0.decl.is(VariableDeclSyntax.self) }).isEmpty else {
            throw CodableMacroError.atLeastOneFieldRequired
        }
    }
}
