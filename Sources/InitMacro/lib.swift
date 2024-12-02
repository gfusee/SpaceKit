import SwiftSyntaxMacros
import SwiftCompilerPlugin

public struct Init {}

@main
struct InitMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Init.self,
    ]
}
