import SwiftSyntax
import SwiftSyntaxMacros

extension Init: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let funcDecl: FunctionDeclSyntax = declaration.as(FunctionDeclSyntax.self) else {
            throw InitMacroError.onlyApplicableToAFunction
        }
        
        guard funcDecl.name.trimmed.description == "initialize" else {
            throw InitMacroError.functionNameMustBeInitialize
        }
        
        let initDeclarations = getInitExportDeclarations(funcDecl: funcDecl, context: context)
        
        return [
            DeclSyntax(initDeclarations.wasmExportedFunction),
            DeclSyntax(initDeclarations.swiftVmInitClass)
        ]
    }
}

fileprivate func getInitExportDeclarations(funcDecl: FunctionDeclSyntax, context: some MacroExpansionContext) -> (wasmExportedFunction: FunctionDeclSyntax, swiftVmInitClass: DeclSyntax) {
    let endpointParams = getInitVariablesDeclarations(
        functionParameters: funcDecl.signature.parameterClause.parameters
    )
    
    let bodySyntax = CodeBlockSyntax(statements: """
    \(raw: endpointParams)
    \(funcDecl.body?.statements ?? [])
    """)
    
    var wasmExportedFunction = FunctionDeclSyntax(
        name: context.makeUniqueName("init"),
        signature: FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(
                parameters: []
            )
        ),
        body: bodySyntax
    )
    
    wasmExportedFunction.attributes = """
    #if WASM
    @_expose(wasm, "init")
    @_cdecl("init")
    #endif
    """
    
    // TODO: duplicate from ControllerMacro's ExtensionMacro.swift
    var abiInputsList: [String] = []
    for parameter in funcDecl.signature.parameterClause.parameters {
        let variableName = (parameter.secondName ?? parameter.firstName).trimmed
        let paramType = parameter.type.trimmed
        let paramTypeABIType = "\(paramType)._abiTypeName"
        let paramIsMulti = "\(paramType)._isMulti"
        
        abiInputsList.append(
            """
            ABIInput(
               name: "\(variableName)",
               type: \(paramTypeABIType),
               multiArg: \(paramIsMulti) ? true : nil
            )
            """
        )
    }
    
    let returnType = funcDecl.signature.returnClause?.type.trimmed
    
    var abiOutputsList: [String] = []
    
    if let returnType = returnType {
        let returnABIType = "\(returnType.trimmed)._abiTypeName"
        let returnIsMulti = "\(returnType.trimmed)._isMulti"
        
        abiOutputsList.append(
            """
            ABIOutput(
               type: \(returnABIType),
               multiResult: \(returnIsMulti) ? true : nil
            )
            """
        )
    }
    
    let abiInputs = abiInputsList.joined(separator: ",\n")
    let abiOutputs = abiOutputsList.joined(separator: ",\n")
    
    let swiftVmInitClass: DeclSyntax = """
    #if !WASM
    class __ContractInit: SwiftVMInit, ABIConstructorExtractor {
        required init() \(bodySyntax)
    
        public static var _extractABIConstructor: ABIConstructor {
           ABIConstructor(
              inputs: [
                 \(raw: abiInputs)
              ],
              outputs: [
                 \(raw: abiOutputs)
              ]
           )
        }
    }
    #endif
    """
    
    return (wasmExportedFunction: wasmExportedFunction, swiftVmInitClass: swiftVmInitClass)
}

fileprivate func getInitVariablesDeclarations(
    functionParameters: FunctionParameterListSyntax
) -> String {
    var argumentDeclarationsList: [String] = []
    
    for parameter in functionParameters {
        let variableName = parameter.secondName ?? parameter.firstName
        let variableType = parameter.type
        
        argumentDeclarationsList.append("let \(variableName) = \(variableType)(topDecodeMulti: &_argsLoader)")
    }
    
    let loaderDeclaration: String? = if !argumentDeclarationsList.isEmpty {
        "var _argsLoader = EndpointArgumentsLoader()"
    } else {
        nil
    }
    
    if let loaderDeclaration = loaderDeclaration {
        // We have to add the loader declaration at the start of the argumentDeclarationsList array
        argumentDeclarationsList.insert(loaderDeclaration, at: 0)
    }
    
    let argumentDeclarations = argumentDeclarationsList.joined(separator: "\n")
    
    return argumentDeclarations
}
