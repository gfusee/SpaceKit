import SwiftSyntax
import SwiftSyntaxMacros

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
        try generateNestedEncodeExtension(enumName: enumName, discriminantsAndCases: discriminantsAndCases),
        try generateTopDecodeExtension(enumName: enumName, discriminantsAndCases: discriminantsAndCases),
        try generateTopDecodeMultiExtension(enumName: enumName),
        try generateNestedDecodeExtension(enumName: enumName, discriminantsAndCases: discriminantsAndCases)
    ]
}

fileprivate func generateTopEncodeExtension(enumName: TokenSyntax) throws -> ExtensionDeclSyntax {
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: enumName),
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
            func depEncode<O: NestedEncodeOutput>(dest: inout O) {
                switch self {
                    \(raw: nestedEncodeFieldsCalls)
                }
            }
        }
        """
    )
}

fileprivate func generateTopDecodeExtension(enumName: TokenSyntax, discriminantsAndCases: [(UInt8, EnumCaseElementSyntax)]) throws -> ExtensionDeclSyntax {
    // TODO: Add tests that ensures we cannot provide a larger buffer than needed (cf. defer scope)
    
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: enumName),
        memberBlock: """
        : TopDecode {
            public static func topDecode(input: MXBuffer) -> \(enumName) {
                var input = BufferNestedDecodeInput(buffer: input)
        
                defer {
                    guard !input.canDecodeMore() else {
                        fatalError()
                    }
                }
        
                return \(raw: enumName).depDecode(input: &input)
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
                
                nestedDecodeAssociatedValuesList.append("\(typeName).depDecode(input: &input)")
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
            case \(discriminantAndCase.0): return .\(caseName)\(nestedDecodeAssociatedValues)
            """
        )
    }
    
    let nestedDecodeInitArgs = nestedDecodeInitArgsList.joined(separator: "\n")
    
    // TODO: Add tests that ensures we cannot provide a larger buffer than needed (cf. defer scope)
    
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: enumName),
        memberBlock: """
        : NestedDecode {
            static func depDecode<I: NestedDecodeInput>(input: inout I) -> \(enumName) {
                let _discriminant = UInt8.depDecode(input: &input)
        
                switch _discriminant {
                    \(raw: nestedDecodeInitArgs)
                    default: fatalError()
                }
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
