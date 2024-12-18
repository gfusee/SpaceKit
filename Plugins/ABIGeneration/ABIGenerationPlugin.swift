import PackagePlugin
import Foundation

@main
struct ABIGenerationPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        return []
    }
}
