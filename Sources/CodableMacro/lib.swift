import SwiftSyntaxMacros
import SwiftCompilerPlugin

public struct Codable {}

@main
struct ContractMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Codable.self,
    ]
}
