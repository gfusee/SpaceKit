import SwiftSyntax
import SwiftSyntaxMacros

// TODO: Remove user comments on fields
// TODO: check if the above TODO applies for enums too

// TODO: check if optional fields works with "?"
// TODO: recreate the auto-generate init to make it public

func generateStructConformance(
    structDecl: StructDeclSyntax
) throws -> [ExtensionDeclSyntax] {
    try structDecl.isValidStruct()
    
    let structName = structDecl.name.trimmed
    let fields = structDecl.getFields()
    
    var results = [
        try generateTopEncodeExtension(structName: structName),
        try generateTopEncodeMultiExtension(structName: structName),
        try generateNestedEncodeExtension(structName: structName, fields: fields),
        try generateTopDecodeExtension(structName: structName, fields: fields),
        try generateTopDecodeMultiExtension(structName: structName),
        try generateNestedDecodeExtension(structName: structName, fields: fields),
        try generateArrayItemExtension(structName: structName, fields: fields)
    ]
    
    #if !WASM
    results.append((try generateABITypeExtractorExtension(structName: structName, fields: fields)).as(ExtensionDeclSyntax.self)!)
    #endif
    
    return results
}

fileprivate func generateTopEncodeExtension(structName: TokenSyntax) throws -> ExtensionDeclSyntax {
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: structName),
        memberBlock: """
        : TopEncode {
            @inline(__always)
            public func topEncode<EncodeOutput>(output: inout EncodeOutput) where EncodeOutput: TopEncodeOutput {
                var nestedEncoded = Buffer()
                self.depEncode(dest: &nestedEncoded)
                nestedEncoded.topEncode(output: &output)
            }
        }
        """
    )
}

fileprivate func generateTopEncodeMultiExtension(structName: TokenSyntax) throws -> ExtensionDeclSyntax {
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: structName),
        memberBlock: """
        : TopEncodeMulti {}
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
            @inline(__always)
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
            @inline(__always)
            public init(topDecode input: Buffer) {
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
            @inline(__always)
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
            
            @inline(__always)
            public static func decodeArrayPayload(payload: Buffer) -> \(structName) {
                var payloadInput = BufferNestedDecodeInput(buffer: payload)
                
                \(raw: payloadInputsDeclarations)
        
                guard !payloadInput.canDecodeMore() else {
                    fatalError()
                }
                
                return \(raw: structName)(
                    \(raw: decodeArrayPayloadInitArgs)
                )
            }
              
            @inline(__always)
            public func intoArrayPayload() -> Buffer {
                var totalPayload = Buffer()
        
                \(raw: intoArrayPayloadInitArgs)
        
                return totalPayload
            }
        }
        """
    )
}

fileprivate func generateABITypeExtractorExtension(structName: TokenSyntax, fields: [VariableDeclSyntax]) throws -> DeclSyntax {
    var fieldsInitsList: [String] = []
    for field in fields {
        guard let fieldType = field.bindings.first!.typeAnnotation?.type else {
            throw CodableMacroError.allFieldsShouldHaveAType
        }
        
        let fieldName = field.bindings.first!.pattern
        fieldsInitsList.append(
            """
                            ABITypeStructField(
                                name: "\(fieldName)",
                                type: \(fieldType)._abiTypeName
                            )
            """
        )
    }
    
    let fieldsInits = fieldsInitsList.joined(separator: ",\n")
    
    return """
    extension \(structName): ABITypeExtractor {
        public static var _abiTypeName: String {
            "\(structName)"
        }
    
        public static var _extractABIType: ABIType? {
            ABIType.struct(
                fields: [
                    \(raw: fieldsInits)
                ]
            )
        }
    }
    """
}
