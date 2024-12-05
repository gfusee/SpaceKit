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
        
        results.append(swiftVMCompatibleConformance)
        results.append(contractEndpointSelectorConformance)
        #endif
        
        return results
    }
}

func getContractEndpointSelectorConformance(
    structDecl: StructDeclSyntax,
    functions: [FunctionDeclSyntax]
) throws -> ExtensionDeclSyntax {
    let structName = structDecl.name.trimmed
    
    var endpointCasesList: [String] = []
    
    for function in functions {
        guard function.isEndpoint() else {
            continue
        }
        
        let functionName = function.name.trimmed
        
        endpointCasesList.append("""
        case "\(functionName)":
            \(structName).\(functionName)()
        """)
    }
    
    let endpointCases = endpointCasesList.joined(separator: "\n")
    
    let extensionSyntax = try ExtensionDeclSyntax(
        "extension \(structName): ContractEndpointSelector"
    ) {
        """
        @inline(__always)
        public mutating func _callEndpoint(name: String) {
            switch name {
            \(raw: endpointCases)
            default:
                API.throwFunctionNotFoundError()
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
        typealias TestableContractType = Self.Testable
        """
    }
    
    return extensionSyntax
}
