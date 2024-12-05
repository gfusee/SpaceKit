import SwiftSyntaxMacros
import SwiftCompilerPlugin

public struct Controller {}

@main
struct ControllerMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Controller.self,
    ]
}
