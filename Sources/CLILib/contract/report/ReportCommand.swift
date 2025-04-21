import Foundation
import ArgumentParser

struct ReportCommandOptions: ParsableArguments {
    @Option(help: "WebAssembly module path.")
    var wasmPath: String
}

struct ReportCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "report",
        abstract: "Perform checks on a build .wasm contract file."
    )
    
    @OptionGroup var options: ReportCommandOptions
    
    mutating func run() async throws(CLIError) {
        try reportContract(wasmPath: self.options.wasmPath)
    }
}

func reportContract(wasmPath: String) throws(CLIError) {
    try assertNoMemoryAllocations(wasmPath: wasmPath)
}
