import SwiftSyntax
import SwiftSyntaxMacros

extension Controller: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw ControllerMacroError.onlyApplicableToStruct
        }
        
        try structDecl.isValidStruct()
        
        var results: [ExtensionDeclSyntax] = []
        
        // Pre-processor instructions are not allowed in ExtensionDeclSyntax. They work here, even though it's not ideal
        #if !WASM
        let functionDecls = structDecl.memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
        
        let contractEndpointSelectorConformance = try getContractEndpointSelectorConformance(structDecl: structDecl, functions: functionDecls)
        let swiftVMCompatibleConformance = try getSwiftVMCompatibleConformance(structDecl: structDecl)
        let abiEndpointsExtractorConformance = (try getABIEndpointsExtractorConformance(structDecl: structDecl, functions: functionDecls)).as(ExtensionDeclSyntax.self)!
        
        results.append(swiftVMCompatibleConformance)
        results.append(contractEndpointSelectorConformance)
        results.append(abiEndpointsExtractorConformance)
        #endif
        
        return results
    }
}

func getContractEndpointSelectorConformance(
    structDecl: StructDeclSyntax,
    functions: [FunctionDeclSyntax]
) throws -> ExtensionDeclSyntax {
    let structName = structDecl.name.trimmed
    
    var endpointCasesList: [String] = [
        """
        case "init":
            Self.__contractInit()
            return true
        """
    ]
    
    for function in functions {
        guard function.isEndpoint() else {
            continue
        }
        
        let functionName = function.name.trimmed
        
        endpointCasesList.append("""
        case "\(functionName)":
            \(structName).\(functionName)()
            return true
        """)
    }
    
    let endpointCases = endpointCasesList.joined(separator: "\n")
    
    let extensionSyntax = try ExtensionDeclSyntax(
        "extension \(structName): ContractEndpointSelector"
    ) {
        """
        @inline(__always)
        public mutating func _callEndpoint(name: String) -> Bool {
            switch name {
            \(raw: endpointCases)
            default:
                return false
            }
        }
        """
    }
    
    return extensionSyntax
}

func getSwiftVMCompatibleConformance(
    structDecl: StructDeclSyntax
) throws -> ExtensionDeclSyntax {
    let structName = structDecl.name.trimmed
    
    let extensionSyntax = try ExtensionDeclSyntax(
        "extension \(structName): SwiftVMCompatibleContract"
    ) {
        """
        public typealias TestableContractType = Self.Testable
        """
    }
    
    return extensionSyntax
}

func getABIEndpointsExtractorConformance(
    structDecl: StructDeclSyntax,
    functions: [FunctionDeclSyntax]
) throws -> DeclSyntax {
    let structName = structDecl.name.trimmed
    
    var requiredABITypesExpressionsList: [String] = []
    var abiEndpointsInitList: [String] = []
    
    for function in functions {
        var function = function
        guard function.isEndpoint() else {
            continue
        }
        
        if function.isCallback() {
            function.attributes = function.attributes.filter { attributes in
                attributes.description.trimmingCharacters(in: .whitespacesAndNewlines) != "@Callback"
            }
        }
        
        var abiInputsList: [String] = []
        for parameter in function.signature.parameterClause.parameters {
            let variableName = (parameter.secondName ?? parameter.firstName).trimmed
            let paramType = parameter.type.trimmed
            let paramTypeABITypeName = "\(paramType)._abiTypeName"
            let paramTypeABIType = "\(paramType)._extractABIType"
            let paramIsMulti = "\(paramType)._isMulti"
            
            abiInputsList.append(
                """
                ABIInput(
                   name: "\(variableName)",
                   type: \(paramTypeABITypeName),
                   multiArg: \(paramIsMulti) ? true : nil
                )
                """
            )
            
            requiredABITypesExpressionsList.append(
                "types[\"\(paramType)\"] = \(paramTypeABIType)"
            )
        }
        
        let returnType = function.signature.returnClause?.type.trimmed
        
        var abiOutputsList: [String] = []
        
        if let returnType = returnType?.trimmed {
            let returnABITypeName = "\(returnType)._abiTypeName"
            let returnTypeABIType = "\(returnType)._extractABIType"
            let returnIsMulti = "\(returnType)._isMulti"
            
            abiOutputsList.append(
                """
                ABIOutput(
                   type: \(returnABITypeName),
                   multiResult: \(returnIsMulti) ? true : nil
                )
                """
            )
            
            requiredABITypesExpressionsList.append(
                "types[\"\(returnType)\"] = \(returnTypeABIType)"
            )
        }
        
        let functionName = function.name.trimmed
        
        var isOnlyOwner: Bool? = nil
        if let functionBody = function.body {
            if let firstStatement = functionBody.statements.first {
                let firstStatementDescription = firstStatement.trimmed.description
                
                if firstStatementDescription.starts(with: "assertOwner()") || firstStatementDescription.starts(with: "SpaceKit.assertOwner()") {
                    isOnlyOwner = true
                }
            }
        }
        
        let isOnlyOwnerString = isOnlyOwner != nil ? "\(isOnlyOwner!)" : "nil"
        
        let abiInputs = abiInputsList.joined(separator: ",\n")
        let abiOutputs = abiOutputsList.joined(separator: ",\n")

        let abiEndpointsInitParamsList: [String] = [
            """
            name: "\(functionName)"
            """,
            "onlyOwner: \(isOnlyOwnerString)",
            "mutability: .mutable",
            "payableInTokens: [ABIEndpointPayableInTokens.wildcard]",
            """
            inputs: [
                \(abiInputs)
            ]
            """,
            """
            outputs: [
                \(abiOutputs)
            ]
            """
        ]
        
        let abiEndpointsInitParams = abiEndpointsInitParamsList.joined(separator: ",\n")
        
        abiEndpointsInitList.append(
            """
            ABIEndpoint(
                \(abiEndpointsInitParams)
            )
            """
        )
    }
    
    let abiEndpointsInit = abiEndpointsInitList.joined(separator: ",\n")
    let requiredABITypesExpressions = requiredABITypesExpressionsList.joined(separator: "\n")
    
    return """
    extension \(structName): ABIEndpointsExtractor {
       public static var _extractABIEndpoints: [ABIEndpoint] {
          [
             \(raw: abiEndpointsInit)
          ]
       }
    
       public static var _extractRequiredABITypes: [String : ABIType] {
          var types: [String : ABIType] = [:]
          \(raw: requiredABITypesExpressions)
    
          return types
       }
    } 
    """
}
