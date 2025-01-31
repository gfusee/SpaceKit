import SwiftSyntax

extension EnumDeclSyntax {
    func isValidEnum() throws(ProxyMacroError) {
        if let inheritenceClause = self.inheritanceClause {
            for _ in inheritenceClause.inheritedTypes {
                throw ProxyMacroError.noEnumInheritenceOrRawValueAllowed
            }
        }
    }
}
