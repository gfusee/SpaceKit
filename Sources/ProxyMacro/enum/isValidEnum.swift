import SwiftSyntax

extension EnumDeclSyntax {
    func isValidEnum() throws(ProxyMacroError) {
        if let inheritenceClause = self.inheritanceClause {
            for type in inheritenceClause.inheritedTypes {
                throw ProxyMacroError.noEnumInheritenceOrRawValueAllowed
            }
        }
    }
}
