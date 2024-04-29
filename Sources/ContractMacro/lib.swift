import SwiftSyntaxMacros
import SwiftCompilerPlugin

public struct Contract {}

@main
struct ContractMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Contract.self,
    ]
}
