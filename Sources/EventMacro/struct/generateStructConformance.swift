import SwiftSyntax
import SwiftSyntaxMacros

// TODO: Remove user comments on fields
// TODO: check if the above TODO applies for enums too

// TODO: check if optional fields works with "?"
// TODO: recreate the auto-generate init to make it public

func generateStructConformance(
    structDecl: StructDeclSyntax,
    dataTypeName: String
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
    dataTypeName: String
) throws -> ExtensionDeclSyntax {
    var nestedEncodeFieldsCallsList: [String] = []
    for field in fields {
        guard let fieldType = field.bindings.first!.typeAnnotation else {
            throw EventMacroError.allFieldsShouldHaveAType
        }
        
        let fieldName = field.bindings.first!.pattern
        let fieldBufferName = "\(fieldName)Buffer"
        nestedEncodeFieldsCallsList.append("""
        var \(fieldBufferName) = MXBuffer()
        self.\(fieldName).topEncode(output: &\(fieldBufferName))
        _indexedArgs = _indexedArgs.appended(\(fieldBufferName))
        """)
    }
    
    let nestedEncodeFieldsCalls = nestedEncodeFieldsCallsList.joined(separator: "\n")
    
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: structName),
        memberBlock: """
        {
            public func emit(data: \(raw: dataTypeName)) {
                var _indexedArgs: MXArray<MXBuffer> = MXArray()
                _indexedArgs = _indexedArgs.appended("\(structName)")
                var _encodedData = MXBuffer()
                data.topEncode(output: &_encodedData)
        
                \(raw: nestedEncodeFieldsCalls)
        
                MultiversX.emitEvent(topicsHandle: _indexedArgs.buffer.handle, dataHandle: _encodedData.handle)
            }
        }
        """
    )
}
