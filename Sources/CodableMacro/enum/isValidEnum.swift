import SwiftSyntax

extension EnumDeclSyntax {
    func isValidEnum() throws(CodableMacroError) {
        if let inheritenceClause = self.inheritanceClause {
            let allowedTypes = ["Equatable"]
            for type in inheritenceClause.inheritedTypes {
                if !allowedTypes.contains(String(describing: type.type.trimmed)) {
                    throw CodableMacroError.noEnumInheritenceOrRawValueAllowed
                }
            }
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