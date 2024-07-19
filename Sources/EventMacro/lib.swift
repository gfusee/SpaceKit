import SwiftSyntaxMacros
import SwiftCompilerPlugin

public struct Event {}

@main
struct EventMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Event.self,
    ]
}
