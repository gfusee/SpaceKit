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
    var argBufferInstantiationKeyword: String = "let"
    for discriminantAndCase in discriminantsAndCases {
        let caseName = discriminantAndCase.1.name.trimmed
        var associatedValuesInstantiationsList: [String] = []
        var associatedValuesPushArgsList: [String] = []
        
        if let associatedValues = discriminantAndCase.1.parameterClause?.parameters {
            for associatedValue in associatedValues.enumerated() {
                let valueName = "value\(associatedValue.offset)"
                
                associatedValuesInstantiationsList.append("let \(valueName)")
                associatedValuesPushArgsList.append("_argBuffer.pushArg(arg: \(valueName))")
                argBufferInstantiationKeyword = "var"
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
    
    // TODO: use the esdtTransfers parameter for both call, callAndIgnoreResult and registerPromise
    
    return ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: enumName),
        memberBlock: """
        {
            public func call<T: TopDecodeMulti>(
                receiver: Address,
                egldValue: BigUint = 0,
                esdtTransfers: Vector<TokenPayment> = Vector()
            ) -> T {
                let (_endpointName, _argBuffer) = self._getEndpointNameAndArgs()
        
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
                esdtTransfers: Vector<TokenPayment> = Vector()
            ) {
                let _: IgnoreValue = self.call(
                    receiver: receiver,
                    egldValue: egldValue,
                    esdtTransfers: esdtTransfers
                )
            }
        
            public func registerPromiseRaw(
                receiver: Address,
                gas: UInt64,
                egldValue: BigUint = 0,
                esdtTransfers: Vector<TokenPayment> = Vector(),
                callbackName: StaticString? = nil,
                callbackArgs: ArgBuffer? = nil,
                gasForCallback: UInt64? = nil
            ) {
                let (_endpointName, _argBuffer) = self._getEndpointNameAndArgs()
        
                ContractCall(
                    receiver: receiver,
                    endpointName: _endpointName,
                    argBuffer: _argBuffer
                ).registerPromiseRaw(
                    gas: gas,
                    value: egldValue,
                    callbackName: callbackName,
                    callbackArgs: callbackArgs,
                    gasForCallback: gasForCallback
                )
            }
        
            public func registerPromise(
                receiver: Address,
                gas: UInt64,
                egldValue: BigUint = 0,
                esdtTransfers: Vector<TokenPayment> = Vector(),
                callback: CallbackParams? = nil
            ) {
                self.registerPromiseRaw(
                    receiver: receiver,
                    gas: gas,
                    egldValue: egldValue,
                    callbackName: callback?.name,
                    callbackArgs: callback?.args,
                    gasForCallback: callback?.gas
                )
            }
        
            private func _getEndpointNameAndArgs() -> (Buffer, ArgBuffer) {
                let _endpointName: Buffer
                \(raw: argBufferInstantiationKeyword) _argBuffer = ArgBuffer()
                switch self {
                    \(raw: calls)
                }
        
                return (_endpointName, _argBuffer)
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
