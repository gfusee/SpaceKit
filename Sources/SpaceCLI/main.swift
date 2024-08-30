import Foundation
import Commander

let INITIAL_PWD = FileManager.default.currentDirectoryPath

let main = Group { rootGroup in
    rootGroup.group("contract") { contractGroup in
        contractGroup.command("new") {
            print("new")
        }
        
        contractGroup.command("build", Option<String>("contract", default: "")) { contract in
            try buildContract(contractName: contract.isEmpty ? nil : "")
        }
    }
}

do {
    try main.run(ArgumentParser(arguments: Array(CommandLine.arguments.dropFirst())))
} catch let error as CLIError {
    print("Space CLI error:\n\n\(error)")
}
