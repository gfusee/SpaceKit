import SwiftSyntax
import SwiftSyntaxMacros

// TODO: check if optional fields works with "?"

func generateEnumExtension(
    enumDecl: EnumDeclSyntax
) throws -> [ExtensionDeclSyntax] {
    try enumDecl.isValidEnum()
    
    let enumName = enumDecl.name.trimmed
    
    let members = enumDecl.memberBlock.members
    let cases = members
        .compactMap({ $0.decl.as(EnumCaseDeclSyntax.self) })
    
    let discriminantsAndCases = getDiscriminantForCase(cases: cases)
    
    return [
        try generateCallExtension(enumName: enumName, discriminantsAndCases: discriminantsAndCases)
    ]
}

fileprivate func generateCallExtension(enumName: TokenSyntax, discriminantsAndCases: [(UInt8, EnumCaseElementSyntax)]) throws -> ExtensionDeclSyntax {
    var callsList: [String] = []
    for discriminantAndCase in discriminantsAndCases {
        let caseName = discriminantAndCase.1.name.trimmed
        var associatedValuesInstantiationsList: [String] = []
        var associatedValuesPushArgsList: [String] = []
        
        if let associatedValues = discriminantAndCase.1.parameterClause?.parameters {
            for associatedValue in associatedValues.enumerated() {
                let valueName = "value\(associatedValue.offset)"
                
                associatedValuesInstantiationsList.append("let \(valueName)")
                associatedValuesPushArgsList.append("_argBuffer.pushArg(arg: \(valueName))")
            }
        }
        
        let associatedValuesInstantiations = if associatedValuesInstantiationsList.isEmpty {
            ""
        } else {
            "(\(associatedValuesInstantiationsList.joined(separator: ", ")))"
        }
        
        let associatedValuesPushArgs = associatedValuesPushArgsList.joined(separator: "\n")
        
        callsList.append("""
            case .\(caseName)\(associatedValuesInstantiations):
            \(associatedValuesPushArgs)
            _endpointName = "\(caseName)"
            """.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
    
    let calls = callsList.joined(separator: "\n")
    
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: enumName),
        memberBlock: """
        {
            public func call<T: TopDecodeMulti>(
                receiver: Address,
                egldValue: BigUint = 0,
                esdtTransfers: MXArray<TokenPayment> = []
            ) -> T {
                var _argBuffer = ArgBuffer()
                let _endpointName: MXBuffer
                switch self {
                    \(raw: calls)
                }
        
                return ContractCall(
                    receiver: receiver,
                    endpointName: _endpointName,
                    argBuffer: _argBuffer
                ).call(
                    value: egldValue
                )
            }
        
            public func callAndIgnoreResult(
                receiver: Address,
                egldValue: BigUint = 0,
                esdtTransfers: MXArray<TokenPayment> = []
            ) {
                let _: IgnoreValue = self.call(
                    receiver: receiver,
                    egldValue: egldValue,
                    esdtTransfers: esdtTransfers
                )
            }
        
            public func registerPromise(
                callbackName: StaticString,
                gas: UInt64,
                gasForCallback: UInt64,
                callbackArgs: ArgBuffer,
                value: BigUint = 0
            ) {
                ContractCall(
                    receiver: receiver,
                    endpointName: _endpointName,
                    argBuffer: _argBuffer
                ).call(
                    callbackName: callbackName,
                    gas: gas,
                    gasForCallback: gasForCallback,
                    value: value
                )
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
