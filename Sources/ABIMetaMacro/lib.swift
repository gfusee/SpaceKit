import SwiftSyntaxMacros
import SwiftCompilerPlugin

public struct ABIMeta {}

@main
struct ABIMetaPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ABIMeta.self,
    ]
}
