import SwiftSyntaxMacros
import SwiftCompilerPlugin

public struct Proxy {}

@main
struct EventMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Proxy.self,
    ]
}
