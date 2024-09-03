import ArgumentParser

struct ContractCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Contract-related commands",
        subcommands: [BuildCommand.self], aliases: ["contract"]
    )
}
