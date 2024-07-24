import SwiftSyntax
import SwiftSyntaxMacros

// TODO: check if optional fields works with "?"

func generateEnumConformance(
    enumDecl: EnumDeclSyntax
) throws -> [ExtensionDeclSyntax] {
    try enumDecl.isValidEnum()
    
    let enumName = enumDecl.name.trimmed
    
    let members = enumDecl.memberBlock.members
    let cases = members
        .compactMap({ $0.decl.as(EnumCaseDeclSyntax.self) })
    
    let discriminantsAndCases = getDiscriminantForCase(cases: cases)
    
    return [
        try generateTopEncodeExtension(enumName: enumName),
        try generateTopEncodeMultiExtension(enumName: enumName),
        try generateNestedEncodeExtension(enumName: enumName, discriminantsAndCases: discriminantsAndCases),
        try generateTopDecodeExtension(enumName: enumName, discriminantsAndCases: discriminantsAndCases),
        try generateTopDecodeMultiExtension(enumName: enumName),
        try generateNestedDecodeExtension(enumName: enumName, discriminantsAndCases: discriminantsAndCases),
        try generateArrayItemExtension(enumName: enumName, discriminantsAndCases: discriminantsAndCases)
    ]
}

fileprivate func generateTopEncodeExtension(enumName: TokenSyntax) throws -> ExtensionDeclSyntax {
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: enumName),
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

fileprivate func generateTopEncodeMultiExtension(enumName: TokenSyntax) throws -> ExtensionDeclSyntax {
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: enumName),
        memberBlock: """
        : TopEncodeMulti {}
        """
    )
}

fileprivate func generateNestedEncodeExtension(enumName: TokenSyntax, discriminantsAndCases: [(UInt8, EnumCaseElementSyntax)]) throws -> ExtensionDeclSyntax {
    var nestedEncodeFieldsCallsList: [String] = []
    for discriminantAndCase in discriminantsAndCases {
        let caseName = discriminantAndCase.1.name.trimmed
        var associatedValuesInstantiationsList: [String] = []
        var associatedValuesDepEncodeList: [String] = []
        
        if let associatedValues = discriminantAndCase.1.parameterClause?.parameters {
            for associatedValue in associatedValues.enumerated() {
                let valueName = "value\(associatedValue.offset)"
                
                associatedValuesInstantiationsList.append("let \(valueName)")
                associatedValuesDepEncodeList.append("\(valueName).depEncode(dest: &dest)")
            }
        }
        
        let associatedValuesInstantiations = if associatedValuesInstantiationsList.isEmpty {
            ""
        } else {
            "(\(associatedValuesInstantiationsList.joined(separator: ", ")))"
        }
        
        let associatedValuesDepEncode = associatedValuesDepEncodeList.joined(separator: "\n")
        
        nestedEncodeFieldsCallsList.append("""
            case .\(caseName)\(associatedValuesInstantiations):
            UInt8(\(discriminantAndCase.0)).depEncode(dest: &dest)
            \(associatedValuesDepEncode)
            """.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
    
    let nestedEncodeFieldsCalls = nestedEncodeFieldsCallsList.joined(separator: "\n")
    
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: enumName),
        memberBlock: """
        : NestedEncode {
            public func depEncode<O: NestedEncodeOutput>(dest: inout O) {
                switch self {
                    \(raw: nestedEncodeFieldsCalls)
                }
            }
        }
        """
    )
}

fileprivate func generateTopDecodeExtension(enumName: TokenSyntax, discriminantsAndCases: [(UInt8, EnumCaseElementSyntax)]) throws -> ExtensionDeclSyntax {
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: enumName),
        memberBlock: """
        : TopDecode {
            public init(topDecode input: MXBuffer) {
                var nestedDecodeInput = BufferNestedDecodeInput(buffer: input)
        
                if nestedDecodeInput.bufferCount == 0 {
                    smartContractError(message: "Top decode error for \(enumName): empty buffer. Hint: maybe are you trying to retrieve an empty storage?")
                }
        
                defer {
                     require(
                        !nestedDecodeInput.canDecodeMore(),
                        "Top decode error for \(enumName): input too large."
                     )
                }
        
                self = \(raw: enumName)(depDecode: &nestedDecodeInput)
            }
        }
        """
    )
}

fileprivate func generateTopDecodeMultiExtension(enumName: TokenSyntax) throws -> ExtensionDeclSyntax {
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: enumName),
        memberBlock: """
        : TopDecodeMulti {}
        """
    )
}

fileprivate func generateNestedDecodeExtension(enumName: TokenSyntax, discriminantsAndCases: [(UInt8, EnumCaseElementSyntax)]) throws -> ExtensionDeclSyntax {
    var nestedDecodeInitArgsList: [String] = []
    
    for discriminantAndCase in discriminantsAndCases {
        var nestedDecodeAssociatedValuesList: [String] = []
        let caseName = discriminantAndCase.1.name.trimmed
        
        if let associatedValues = discriminantAndCase.1.parameterClause?.parameters {
            for associatedValue in associatedValues {
                guard associatedValue.firstName == nil && associatedValue.secondName == nil else {
                    throw CodableMacroError.enumAssociatedValuesShouldNotBeNamed
                }
                
                let typeName = associatedValue.type.trimmed
                
                nestedDecodeAssociatedValuesList.append("\(typeName)(depDecode: &input)")
            }
        }
        
        let nestedDecodeAssociatedValues = if nestedDecodeAssociatedValuesList.isEmpty {
            ""
        } else {
            """
            (
                \(nestedDecodeAssociatedValuesList.joined(separator: ",\n"))
            )
            """
        }
        
        nestedDecodeInitArgsList.append("""
            case \(discriminantAndCase.0): self = .\(caseName)\(nestedDecodeAssociatedValues)
            """
        )
    }
    
    let nestedDecodeInitArgs = nestedDecodeInitArgsList.joined(separator: "\n")
    
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: enumName),
        memberBlock: """
        : NestedDecode {
            public init(depDecode input: inout some NestedDecodeInput) {
                let _discriminant = UInt8(depDecode: &input)
        
                switch _discriminant {
                    \(raw: nestedDecodeInitArgs)
                    default: fatalError()
                }
            }
        }
        """
    )
}

fileprivate func generateArrayItemExtension(enumName: TokenSyntax, discriminantsAndCases: [(UInt8, EnumCaseElementSyntax)]) throws -> ExtensionDeclSyntax {
    var payloadSizeSumList: [String] = []
    var payloadInputsDeclarationsList: [String] = []
    var decodeArrayPayloadInitArgsList: [String] = []
    var intoArrayPayloadCasesList: [String] = []
    for discriminantAndCase in discriminantsAndCases {
        var decodeArrayPayloadValuesDeclarationList: [String] = []
        var decodeArrayPayloadInitArgsValuesList: [String] = []
        var payloadSizeOperandsList: [String] = ["1"]
        var associatedValuesInstantiationsList: [String] = []
        var associatedValuesIntoArrayPayloadList: [String] = []
        let caseName = discriminantAndCase.1.name.trimmed
        
        if let associatedValues = discriminantAndCase.1.parameterClause?.parameters {
            for associatedValue in associatedValues.enumerated() {
                let typeName = associatedValue.element.type.trimmed
                
                let valueName = "value\(associatedValue.offset)"
                decodeArrayPayloadValuesDeclarationList.append("let \(valueName)Payload = payloadInput.readNextBuffer(length: \(typeName).payloadSize)")
                
                decodeArrayPayloadInitArgsValuesList.append("\(typeName).decodeArrayPayload(payload: \(valueName)Payload)")
                payloadSizeOperandsList.append("\(typeName).payloadSize")
                
                associatedValuesInstantiationsList.append("let \(valueName)")
                associatedValuesIntoArrayPayloadList.append("""
                totalPayload = totalPayload + \(valueName).intoArrayPayload()
                """)
            }
        }
        
        let currentCasePayloadSize = payloadSizeOperandsList.joined(separator: " + ")
        payloadSizeSumList.append(currentCasePayloadSize)
        
        let decodeArrayPayloadValuesDeclaration = decodeArrayPayloadValuesDeclarationList.joined(separator: "\n")
        
        let decodeArrayPayloadInitArgsValues = if decodeArrayPayloadInitArgsValuesList.isEmpty {
            ""
        } else {
            """
            (
                \(decodeArrayPayloadInitArgsValuesList.joined(separator: ",\n"))
            )
            """
        }
        
        decodeArrayPayloadInitArgsList.append("""
            case \(discriminantAndCase.0):
            \(decodeArrayPayloadValuesDeclaration)
            return .\(caseName)\(decodeArrayPayloadInitArgsValues)
            """
        )
        
        let associatedValuesInstantiations = if associatedValuesInstantiationsList.isEmpty {
            ""
        } else {
            "(\(associatedValuesInstantiationsList.joined(separator: ", ")))"
        }
        
        let associatedValuesIntoArrayPayload = associatedValuesIntoArrayPayloadList.joined(separator: "\n")
        
        intoArrayPayloadCasesList.append("""
            case .\(caseName)\(associatedValuesInstantiations):
            currentCasePayloadSize = \(currentCasePayloadSize)
            totalPayload.write(buffer: UInt8(\(discriminantAndCase.0)).intoArrayPayload())
            \(associatedValuesIntoArrayPayload)
            """.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
    
    let payloadSizeSum = payloadSizeSumList.joined(separator: ", ")
    
    let payloadInputsDeclarations = payloadInputsDeclarationsList.joined(separator: "\n")
    let decodeArrayPayloadInitArgs = decodeArrayPayloadInitArgsList.joined(separator: "\n")
    let intoArrayPayloadCases = intoArrayPayloadCasesList.joined(separator: "\n")
    
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: enumName),
        memberBlock: """
        : ArrayItem {
            public static var payloadSize: Int32 {
                return max(\(raw: payloadSizeSum))
            }
            
            public static func decodeArrayPayload(payload: MXBuffer) -> \(enumName) {
                var payloadInput = BufferNestedDecodeInput(buffer: payload)
                
                let _discriminantPayload = payloadInput.readNextBuffer(length: 1)
                let _discriminant = UInt8.decodeArrayPayload(payload: _discriminantPayload)
                        
                switch _discriminant {
                    \(raw: decodeArrayPayloadInitArgs)
                    default: fatalError()
                }
            }
              
            public func intoArrayPayload() -> MXBuffer {
                var totalPayload = MXBuffer()
        
                let currentCasePayloadSize: Int32
                switch self {
                    \(raw: intoArrayPayloadCases)
                }
        
                let trailingZerosCount = \(enumName).payloadSize - currentCasePayloadSize
        
                if trailingZerosCount > 0 {
                    totalPayload = totalPayload + MultiversX.getZeroedBuffer(count: trailingZerosCount)
                }
        
                return totalPayload
            }
        }
        """
    )
}

fileprivate func getDiscriminantForCase(cases: [EnumCaseDeclSyntax]) -> [(UInt8, EnumCaseElementSyntax)] {
    var result: [(UInt8, EnumCaseElementSyntax)] = []
    
    var currentDiscriminant: UInt8 = 0
    for caseDecl in cases {
        for element in caseDecl.elements {
            result.append((currentDiscriminant, element))
            currentDiscriminant += 1
        }
    }
    
    return result
}
