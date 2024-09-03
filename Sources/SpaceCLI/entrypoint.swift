import Foundation
import Basics
import Workspace
import ArgumentParser

actor CurrentTerminalProcess {
    static var process: Process? = nil
}

@main
struct SpaceCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A CLI to perform operations related to the Space framework.",
        subcommands: [ContractCommand.self]
    )
    
    static func run() async throws {
        let signalCallback: sig_t = { signal in
            let task = Task { @MainActor in
                if let terminalProcess = CurrentTerminalProcess.process, terminalProcess.isRunning {
                    print("Interrupting terminal...")
                    terminalProcess.interrupt()
                    print("Terminal interrupted!")
                }
            }
            
            Foundation.exit(signal)
        }

        signal(SIGINT, signalCallback)
    }
}
