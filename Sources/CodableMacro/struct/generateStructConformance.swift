import SwiftSyntax
import SwiftSyntaxMacros

// TODO: Remove user comments on fields
// TODO: check if the above TODO applies for enums too

func generateStructConformance(
    structDecl: StructDeclSyntax
) throws -> [ExtensionDeclSyntax] {
    try structDecl.isValidStruct()
    
    let structName = structDecl.name.trimmed
    let fields = structDecl.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
    
    return [
        try generateTopEncodeExtension(structName: structName),
        try generateNestedEncodeExtension(structName: structName, fields: fields),
        try generateTopDecodeExtension(structName: structName, fields: fields),
        try generateTopDecodeMultiExtension(structName: structName),
        try generateNestedDecodeExtension(structName: structName, fields: fields),
        try generateArrayItemExtension(structName: structName, fields: fields)
    ]
}

fileprivate func generateTopEncodeExtension(structName: TokenSyntax) throws -> ExtensionDeclSyntax {
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: structName),
        memberBlock: """
        : TopEncode {
            public func topEncode<T>(output: inout T) where T: TopEncodeOutput {
                var nestedEncoded = MXBuffer()
                self.depEncode(dest: &nestedEncoded)
                nestedEncoded.topEncode(output: &output)
            }
        }
        """
    )
}

fileprivate func generateNestedEncodeExtension(structName: TokenSyntax, fields: [VariableDeclSyntax]) throws -> ExtensionDeclSyntax {
    var nestedEncodeFieldsCallsList: [String] = []
    for field in fields {
        let fieldName = field.bindings.first!.pattern
        nestedEncodeFieldsCallsList.append("self.\(fieldName).depEncode(dest: &dest)")
    }
    
    let nestedEncodeFieldsCalls = nestedEncodeFieldsCallsList.joined(separator: "\n")
    
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: structName),
        memberBlock: """
        : NestedEncode {
            public func depEncode<O: NestedEncodeOutput>(dest: inout O) {
                \(raw: nestedEncodeFieldsCalls)
            }
        }
        """
    )
}

fileprivate func generateTopDecodeExtension(structName: TokenSyntax, fields: [VariableDeclSyntax]) throws -> ExtensionDeclSyntax {
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: structName),
        memberBlock: """
        : TopDecode {
            public static func topDecode(input: MXBuffer) -> \(structName) {
                var input = BufferNestedDecodeInput(buffer: input)
        
                defer {
                    require(
                        !input.canDecodeMore(),
                        "Top decode error for \(structName): input too large."
                     )
                }
        
                return \(raw: structName).depDecode(input: &input)
            }
        }
        """
    )
}

fileprivate func generateTopDecodeMultiExtension(structName: TokenSyntax) throws -> ExtensionDeclSyntax {
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: structName),
        memberBlock: """
        : TopDecodeMulti {}
        """
    )
}

fileprivate func generateNestedDecodeExtension(structName: TokenSyntax, fields: [VariableDeclSyntax]) throws -> ExtensionDeclSyntax {
    var nestedDecodeInitArgsList: [String] = []
    for field in fields {
        let fieldName = field.bindings.first!.pattern
        guard let fieldType = field.bindings.first!.typeAnnotation else {
            throw CodableMacroError.allFieldsShouldHaveAType
        }
        
        nestedDecodeInitArgsList.append("\(fieldName) \(fieldType).depDecode(input: &input)")
    }
    
    let nestedDecodeInitArgs = nestedDecodeInitArgsList.joined(separator: ",\n")
    
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: structName),
        memberBlock: """
        : NestedDecode {
            public static func depDecode<I: NestedDecodeInput>(input: inout I) -> \(structName) {
                return \(raw: structName)(
                    \(raw: nestedDecodeInitArgs)
                )
            }
        }
        """
    )
}

fileprivate func generateArrayItemExtension(structName: TokenSyntax, fields: [VariableDeclSyntax]) throws -> ExtensionDeclSyntax {
    var payloadSizeOperandsList: [String] = []
    var payloadInputsDeclarationsList: [String] = []
    var decodeArrayPayloadInitArgsList: [String] = []
    for field in fields {
        guard let fieldType = field.bindings.first!.typeAnnotation?.type else {
            throw CodableMacroError.allFieldsShouldHaveAType
        }
        
        let fieldTypePayloadSizeExpression = "\(fieldType).payloadSize"
        
        let fieldName = field.bindings.first!.pattern
        let fieldPayloadName = "\(fieldName)PayloadInput"
        let fieldNamePayloadInputDeclaration = "let \(fieldPayloadName) = payloadInput.readNextBuffer(length: \(fieldTypePayloadSizeExpression))"
        
        payloadSizeOperandsList.append(fieldTypePayloadSizeExpression)
        payloadInputsDeclarationsList.append(fieldNamePayloadInputDeclaration)
        decodeArrayPayloadInitArgsList.append("\(fieldName): \(fieldType).decodeArrayPayload(payload: \(fieldPayloadName))")
    }
    
    let payloadSizeSum = payloadSizeOperandsList.joined(separator: " + ")
    
    let payloadInputsDeclarations = payloadInputsDeclarationsList.joined(separator: "\n")
    let decodeArrayPayloadInitArgs = decodeArrayPayloadInitArgsList.joined(separator: ",\n")
    
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: structName),
        memberBlock: """
        : ArrayItem {
            public static var payloadSize: Int32 {
                return \(raw: payloadSizeSum)
            }
            
            public static func decodeArrayPayload(payload: MXBuffer) -> \(structName) {
                var payloadInput = BufferNestedDecodeInput(buffer: payload)
                
                \(raw: payloadInputsDeclarations)
        
                guard !payloadInput.canDecodeMore() else {
                    fatalError()
                }
                
                return \(raw: structName)(
                    \(raw: decodeArrayPayloadInitArgs)
                )
            }
              
            public func intoArrayPayload() -> MXBuffer {
                fatalError()
            }
        }
        """
    )
}
