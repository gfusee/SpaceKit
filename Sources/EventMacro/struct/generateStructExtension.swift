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
    
    var results = [
        try generateEmitExtension(structName: structName, fields: fields, dataTypeName: dataTypeName),
    ]
    
    #if !WASM
    results.append(
        (try generateABIEventExtractorExtension(structName: structName, fields: fields, dataTypeName: dataTypeName)).as(ExtensionDeclSyntax.self)!
    )
    #endif
    
    return results
}

fileprivate func generateEmitExtension(
    structName: TokenSyntax,
    fields: [VariableDeclSyntax],
    dataTypeName: String?
) throws -> ExtensionDeclSyntax {
    var nestedEncodeFieldsCallsList: [String] = []
    for field in fields {
        guard field.bindings.first!.typeAnnotation != nil else {
            throw EventMacroError.allFieldsShouldHaveAType
        }
        
        let fieldName = field.bindings.first!.pattern
        nestedEncodeFieldsCallsList.append("""
        self.\(fieldName).multiEncode(output: &_indexedArgs)
        """)
    }
    
    let nestedEncodeFieldsCalls = nestedEncodeFieldsCallsList.joined(separator: "\n")
   
    let encodedDataInstantiationKeyword: String
    let functionSignature: String
    let dataTopEncode: String
    
    if let dataTypeName = dataTypeName {
        encodedDataInstantiationKeyword = "var"
        functionSignature = "public func emit(data: \(dataTypeName))"
        dataTopEncode = "data.topEncode(output: &_encodedData)"
    } else {
        encodedDataInstantiationKeyword = "let"
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
                \(raw: encodedDataInstantiationKeyword) _encodedData = Buffer()
                \(raw: dataTopEncode)
        
                \(raw: nestedEncodeFieldsCalls)
        
                SpaceKit.emitEvent(topicsHandle: _indexedArgs.buffer.handle, dataHandle: _encodedData.handle)
            }
        }
        """
    )
}

fileprivate func generateABIEventExtractorExtension(
    structName: TokenSyntax,
    fields: [VariableDeclSyntax],
    dataTypeName: String?
) throws -> DeclSyntax {
    var inputInitsList: [String] = []
    for field in fields {
        guard let fieldType = field.bindings.first!.typeAnnotation?.type else {
            throw EventMacroError.allFieldsShouldHaveAType
        }
        
        let fieldName = field.bindings.first!.pattern
        inputInitsList.append(
            """
                            ABIEventInput(
                                name: "\(fieldName)",
                                type: \(fieldType)._abiTypeName,
                                indexed: true
                            )
            """
        )
    }
    
    if let dataTypeName = dataTypeName {
        inputInitsList.append(
            """
                            ABIEventInput(
                                name: "_data",
                                type: \(dataTypeName)._abiTypeName,
                                indexed: nil
                            )
            """
        )
    }
    
    let inputInits = inputInitsList.joined(separator: ",\n")
    
    return """
    extension \(structName): ABIEventExtractor {
        public static var _extractABIEvent: ABIEvent {
            ABIEvent(
                identifier: "\(structName)",
                inputs: [
                    \(raw: inputInits)
                ]
            )
        }
    }
    """
}
