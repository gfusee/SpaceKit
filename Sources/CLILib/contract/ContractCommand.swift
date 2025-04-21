import ArgumentParser

public struct ContractCommand: AsyncParsableCommand {
    public init() {}
    
    public static let configuration = CommandConfiguration(
        commandName: "contract",
        abstract: "Contract-related commands",
        subcommands: [
            BuildCommand.self,
            ReportCommand.self
        ]
    )
}
