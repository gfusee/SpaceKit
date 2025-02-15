import ArgumentParser

struct ContractCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "contract",
        abstract: "Contract-related commands",
        subcommands: [BuildCommand.self]
    )
}
