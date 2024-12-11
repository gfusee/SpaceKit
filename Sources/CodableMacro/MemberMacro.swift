import SwiftSyntax
import SwiftSyntaxMacros

extension Codable: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            let fields = structDecl.getFields()
            
            return [
                try generatePublicInit(fields: fields)
            ]
        } else {
            return []
        }
    }
}

fileprivate func generatePublicInit(fields: [VariableDeclSyntax]) throws -> DeclSyntax {
    var initParametersList: [String] = []
    var bodySelfAssignationsList: [String] = []
    
    for field in fields {
        guard let fieldType = field.bindings.first!.typeAnnotation?.type else {
            throw CodableMacroError.allFieldsShouldHaveAType
        }
        
        let fieldName = field.bindings.first!.pattern.trimmed
        
        initParametersList.append("\(fieldName): \(fieldType)")
        bodySelfAssignationsList.append("self.\(fieldName) = \(fieldName)")
    }
    
    let initParameters = initParametersList.joined(separator: ",\n")
    let bodySelfAssignations = bodySelfAssignationsList.joined(separator: "\n")
    
    return """
    public init(
        \(raw: initParameters)
    ) {
        \(raw: bodySelfAssignations)
    }
    """
}
