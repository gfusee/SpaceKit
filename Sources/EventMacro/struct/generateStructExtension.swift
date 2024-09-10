import SwiftSyntax
import SwiftSyntaxMacros

// TODO: Remove user comments on fields
// TODO: check if the above TODO applies for enums too

// TODO: check if optional fields works with "?"
// TODO: recreate the auto-generate init to make it public

func generateStructExtension(
    structDecl: StructDeclSyntax,
    dataTypeName: String?
) throws -> [ExtensionDeclSyntax] {
    try structDecl.isValidStruct()
    
    let structName = structDecl.name.trimmed
    let fields = structDecl.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
    
    return [
        try generateEmitExtension(structName: structName, fields: fields, dataTypeName: dataTypeName)
    ]
}

fileprivate func generateEmitExtension(
    structName: TokenSyntax,
    fields: [VariableDeclSyntax],
    dataTypeName: String?
) throws -> ExtensionDeclSyntax {
    var nestedEncodeFieldsCallsList: [String] = []
    for field in fields {
        guard let fieldType = field.bindings.first!.typeAnnotation else {
            throw EventMacroError.allFieldsShouldHaveAType
        }
        
        let fieldName = field.bindings.first!.pattern
        nestedEncodeFieldsCallsList.append("""
        self.\(fieldName).multiEncode(output: &_indexedArgs)
        """)
    }
    
    let nestedEncodeFieldsCalls = nestedEncodeFieldsCallsList.joined(separator: "\n")
    
    let functionSignature: String
    let dataTopEncode: String
    
    if let dataTypeName = dataTypeName {
        functionSignature = "public func emit(data: \(dataTypeName))"
        dataTopEncode = "data.topEncode(output: &_encodedData)"
    } else {
        functionSignature = "public func emit()"
        dataTopEncode = ""
    }
    
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: structName),
        memberBlock: """
        {
             \(raw: functionSignature) {
                var _indexedArgs: Vector<Buffer> = Vector()
                _indexedArgs = _indexedArgs.appended("\(structName)")
                var _encodedData = Buffer()
                \(raw: dataTopEncode)
        
                \(raw: nestedEncodeFieldsCalls)
        
                Space.emitEvent(topicsHandle: _indexedArgs.buffer.handle, dataHandle: _encodedData.handle)
            }
        }
        """
    )
}
