import SwiftSyntax
import SwiftSyntaxMacros

// TODO: check if optional fields works with "?"

func generateFuncConformance(
    funcDecl: FunctionDeclSyntax
) throws(CallbackMacroError) -> [DeclSyntax] {
    return [
        try generateDollarFunction(callbackFuncDecl: funcDecl)
    ]
}

func generateDollarFunction(callbackFuncDecl: FunctionDeclSyntax) throws(CallbackMacroError) -> DeclSyntax {
    var signature = callbackFuncDecl.signature
    signature.returnClause = ReturnClauseSyntax(
        type: TypeSyntax(stringLiteral: "CallbackParams")
    )
    
    let hasParameters = !signature.parameterClause.parameters.isEmpty
    
    var commaIfNeeded = ""
    var body: String = "let _callbackArgs = ArgBuffer()"
    if hasParameters {
        commaIfNeeded = ", "
        body = "var _callbackArgs = ArgBuffer()"
    }
    
    for arg in signature.parameterClause.parameters {
        let argName = (arg.secondName ?? arg.firstName).trimmed
        body += "_callbackArgs.pushArg(arg: \(argName))"
    }
    signature.parameterClause.parameters.append("\(raw: commaIfNeeded)gasForCallback: UInt64")
    
    body += """
    return CallbackParams(
        name: "\(callbackFuncDecl.name.trimmed)",
        args: _callbackArgs,
        gas: gasForCallback
    )
    """
    
    let resultDecl = FunctionDeclSyntax(
        modifiers: [
            DeclModifierSyntax.init(name: .keyword(.package)),
        ],
        name: "$\(callbackFuncDecl.name)",
        signature: signature,
        bodyBuilder: {
            "\(raw: body)"
        }
    )
    
    return DeclSyntax(stringLiteral: "\(resultDecl.formatted())")
}
