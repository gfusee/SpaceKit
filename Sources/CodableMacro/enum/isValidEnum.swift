import SwiftSyntax

extension EnumDeclSyntax {
    func isValidEnum() throws(CodableMacroError) {
        guard self.inheritanceClause == nil else {
            throw CodableMacroError.noEnumInheritenceOrRawValueAllowed
        }
        
        let members = self.memberBlock.members
        
        let cases = members
            .compactMap({ $0.decl.as(EnumCaseDeclSyntax.self) })
            .flatMap( { $0.elements } )
        
        guard !cases.isEmpty else {
            throw CodableMacroError.atLeastOneCaseRequired
        }
        
        guard cases.count <= 255 else {
            throw CodableMacroError.tooManyEnumCases
        }
    }
}
