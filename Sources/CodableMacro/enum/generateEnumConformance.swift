import SwiftSyntax
import SwiftSyntaxMacros

// TODO: check if optional fields works with "?"

func generateEnumConformance(
    enumDecl: EnumDeclSyntax
) throws -> [ExtensionDeclSyntax] {
    try enumDecl.isValidEnum()
    
    let enumName = enumDecl.name.trimmed
    
    let members = enumDecl.memberBlock.members
    let cases: [EnumCaseDeclSyntax] = members
        .compactMap { member in
            guard var caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else {
                return nil
            }
            
            caseDecl.trailingTrivia = Trivia(pieces: [])
            
            return caseDecl
        }
    
    let discriminantsAndCases = getDiscriminantForCase(cases: cases)
    
    var results = [
        try generateTopEncodeExtension(enumName: enumName, discriminantsAndCases: discriminantsAndCases),
        try generateTopEncodeMultiExtension(enumName: enumName),
        try generateNestedEncodeExtension(enumName: enumName, discriminantsAndCases: discriminantsAndCases),
        try generateTopDecodeExtension(enumName: enumName, discriminantsAndCases: discriminantsAndCases),
        try generateTopDecodeMultiExtension(enumName: enumName),
        try generateNestedDecodeExtension(enumName: enumName, discriminantsAndCases: discriminantsAndCases),
        try generateArrayItemExtension(enumName: enumName, discriminantsAndCases: discriminantsAndCases)
    ]
    
    #if !WASM
    results.append((try generateABITypeExtractorExtension(enumName: enumName, discriminantsAndCases: discriminantsAndCases)).as(ExtensionDeclSyntax.self)!)
    #endif
    
    return results
}

fileprivate func generateTopEncodeExtension(enumName: TokenSyntax, discriminantsAndCases: [(UInt8, EnumCaseElementSyntax)]) throws -> ExtensionDeclSyntax {
    let firstCase = discriminantsAndCases[0].1
    let nestedEncodedInstantiationKeyword: String
    let guardFirstCaseDefaultIfNeeded: String
    let depEncodeLogicIfNeeded: String
    
    if discriminantsAndCases.count >= 2 {
        nestedEncodedInstantiationKeyword = "var"
        
        guardFirstCaseDefaultIfNeeded = """
        default:
            break
        """
        
        depEncodeLogicIfNeeded = """
        self.depEncode(dest: &nestedEncoded)
        nestedEncoded.topEncode(output: &output)
        """
    } else {
        nestedEncodedInstantiationKeyword = "let"
        
        guardFirstCaseDefaultIfNeeded = ""
        
        depEncodeLogicIfNeeded = ""
    }
    
    let guardFirstCase = if shouldTopEncodeEmptyWhenFirstCase(firstCase: firstCase) {
        """
        switch self {
        case .\(firstCase.name.trimmed):
            nestedEncoded.topEncode(output: &output)
            return
        \(guardFirstCaseDefaultIfNeeded)
        }
        """
    } else {
        ""
    }
        
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: enumName),
        memberBlock: """
        : TopEncode {
            @inline(__always)
            public func topEncode<EncodeOutput>(output: inout EncodeOutput) where EncodeOutput: TopEncodeOutput {
                \(raw: nestedEncodedInstantiationKeyword) nestedEncoded = Buffer()
                \(raw: guardFirstCase)
                \(raw: depEncodeLogicIfNeeded)
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
            @inline(__always)
            public init(topDecode input: Buffer) {
                var nestedDecodeInput = BufferNestedDecodeInput(buffer: input)
        
                if nestedDecodeInput.bufferCount == 0 {
                    \(raw: getTopDecodeWhenEmptyIfPossible(enumName: enumName, firstCase: discriminantsAndCases[0].1))
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
            @inline(__always)
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
    let payloadSizeReturnValue = if payloadSizeSumList.count == 1 {
        payloadSizeSum
    } else {
        "max(\(payloadSizeSum))"
    }
    
    let decodeArrayPayloadInitArgs = decodeArrayPayloadInitArgsList.joined(separator: "\n")
    let intoArrayPayloadCases = intoArrayPayloadCasesList.joined(separator: "\n")
    
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: enumName),
        memberBlock: """
        : ArrayItem {
            public static var payloadSize: Int32 {
                return \(raw: payloadSizeReturnValue)
            }
            
            @inline(__always)
            public static func decodeArrayPayload(payload: Buffer) -> \(enumName) {
                var payloadInput = BufferNestedDecodeInput(buffer: payload)
                
                let _discriminantPayload = payloadInput.readNextBuffer(length: 1)
                let _discriminant = UInt8.decodeArrayPayload(payload: _discriminantPayload)
                        
                switch _discriminant {
                    \(raw: decodeArrayPayloadInitArgs)
                    default: fatalError()
                }
            }
              
            @inline(__always)
            public func intoArrayPayload() -> Buffer {
                var totalPayload = Buffer()
        
                let currentCasePayloadSize: Int32
                switch self {
                    \(raw: intoArrayPayloadCases)
                }
        
                let trailingZerosCount = \(enumName).payloadSize - currentCasePayloadSize
        
                if trailingZerosCount > 0 {
                    totalPayload = totalPayload + SpaceKit.getZeroedBuffer(count: trailingZerosCount)
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

fileprivate func shouldTopEncodeEmptyWhenFirstCase(firstCase: EnumCaseElementSyntax) -> Bool {
    // TODO: add tests
    return firstCase.parameterClause == nil
}

fileprivate func getTopDecodeWhenEmptyIfPossible(enumName: TokenSyntax, firstCase: EnumCaseElementSyntax) -> String {
    // TODO: add tests
    let cannotTopDecodedError = """
        smartContractError(message: "Top decode error for \(enumName): empty buffer. Hint: maybe are you trying to retrieve an empty storage?")
        """
    
    guard firstCase.parameterClause == nil else {
        return cannotTopDecodedError
    }
    
    return """
    self = .\(firstCase.name.trimmed)
    return
    """
}

fileprivate func generateABITypeExtractorExtension(enumName: TokenSyntax, discriminantsAndCases: [(UInt8, EnumCaseElementSyntax)]) throws -> DeclSyntax {
    var variantsInitsList: [String] = []
    for discriminantAndCase in discriminantsAndCases {
        let caseName = discriminantAndCase.1.name.trimmed
        
        var fieldsInitsList: [String] = []
        
        if let associatedValues = discriminantAndCase.1.parameterClause?.parameters {
            var associatedValueName = 0
            
            for associatedValue in associatedValues {
                guard associatedValue.firstName == nil && associatedValue.secondName == nil else {
                    throw CodableMacroError.enumAssociatedValuesShouldNotBeNamed
                }
                
                let typeName = associatedValue.type.trimmed
                
                fieldsInitsList.append(
                    """
                    ABITypeStructField(
                        name: "\(associatedValueName)",
                        type: \(typeName)._abiTypeName
                    )
                    """
                )
                
                associatedValueName += 1
            }
        }
        
        var initParametersLists = [
            """
            name: "\(caseName)"
            """,
            """
            discriminant: \(discriminantAndCase.0)
            """
        ]
        
        if !fieldsInitsList.isEmpty {
            let fieldsInits = fieldsInitsList.joined(separator: ",\n")
            
            initParametersLists.append(
                """
                fields: [
                    \(fieldsInits)
                ]
                """
            )
        }
        
        let initParameters = initParametersLists.joined(separator: ",\n")
        
        variantsInitsList.append(
            """
                            ABITypeEnumVariant(
                                \(initParameters)
                            )
            """
        )
    }
    
    let variantsInits = variantsInitsList.joined(separator: ",\n")
    
    return """
    extension \(enumName): ABITypeExtractor {
        public static var _abiTypeName: String {
            "\(enumName)"
        }
    
        public static var _extractABIType: ABIType? {
            ABIType.enum(
                variants: [
                    \(raw: variantsInits)
                ]
            )
        }
    }
    """
}
