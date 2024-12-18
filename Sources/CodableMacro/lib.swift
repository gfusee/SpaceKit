import SwiftSyntaxMacros
import SwiftCompilerPlugin

public struct Codable {}

@main
struct CodableMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Codable.self,
    ]
}
