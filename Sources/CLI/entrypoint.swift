import Foundation
import SpaceKitCLILib
import ArgumentParser

@main
struct SpaceKitCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "space",
        abstract: "A CLI to perform operations related to the SpaceKit framework.",
        subcommands: [
            ContractCommand.self,
            InitCommand.self
        ]
    )
    
    static func run() async throws {
        let signalCallback: sig_t = { signal in
            Task { @MainActor in
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
