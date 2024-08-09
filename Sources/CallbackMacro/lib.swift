import SwiftSyntaxMacros
import SwiftCompilerPlugin

public struct Callback {}

@main
struct CallbackMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Callback.self,
    ]
}
