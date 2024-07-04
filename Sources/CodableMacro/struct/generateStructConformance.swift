import SwiftSyntax
import SwiftSyntaxMacros

// TODO: Remove user comments on fields
// TODO: check if the above TODO applies for enums too

// TODO: check if optional fields works with "?"

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
            @inline(__always)
            public func topEncode<EncodeOutput>(output: inout EncodeOutput) where EncodeOutput: TopEncodeOutput {
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
            public init(topDecode input: MXBuffer) {
                var input = BufferNestedDecodeInput(buffer: input)
        
                defer {
                    require(
                        !input.canDecodeMore(),
                        "Top decode error for \(structName): input too large."
                     )
                }
        
                self = \(raw: structName)(depDecode: &input)
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
        
        nestedDecodeInitArgsList.append("\(fieldName) \(fieldType)(depDecode: &input)")
    }
    
    let nestedDecodeInitArgs = nestedDecodeInitArgsList.joined(separator: ",\n")
    
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: structName),
        memberBlock: """
        : NestedDecode {
            public init(depDecode input: inout some NestedDecodeInput) {
                self = \(raw: structName)(
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
    var intoArrayPayloadInitArgsList: [String] = []
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
        intoArrayPayloadInitArgsList.append("totalPayload = totalPayload + \(fieldName).intoArrayPayload()")
    }
    
    let payloadSizeSum = payloadSizeOperandsList.joined(separator: " + ")
    
    let payloadInputsDeclarations = payloadInputsDeclarationsList.joined(separator: "\n")
    let decodeArrayPayloadInitArgs = decodeArrayPayloadInitArgsList.joined(separator: ",\n")
    let intoArrayPayloadInitArgs = intoArrayPayloadInitArgsList.joined(separator: "\n")
    
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
                var totalPayload = MXBuffer()
        
                \(raw: intoArrayPayloadInitArgs)
        
                return totalPayload
            }
        }
        """
    )
}
