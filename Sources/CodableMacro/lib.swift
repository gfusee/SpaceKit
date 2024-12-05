import SwiftSyntaxMacros
import SwiftCompilerPlugin

public struct Codable {}

@main
struct ControllerMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Codable.self,
    ]
}
