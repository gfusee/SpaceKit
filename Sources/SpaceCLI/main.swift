import Foundation
import Basics
import Workspace
import Commander

let INITIAL_PWD = FileManager.default.currentDirectoryPath
var TERMINAL_PROCESS: Process? = nil

let signalCallback: sig_t = { signal in
    if let terminalProcess = TERMINAL_PROCESS, terminalProcess.isRunning {
        terminalProcess.interrupt()
    }
    
    exit(signal)
}

signal(SIGINT, signalCallback)

let main = Group { rootGroup in
    rootGroup.group("contract") { contractGroup in
        contractGroup.command("new") {
            try initialize()
            print("new")
        }
        
        contractGroup.command("build", Option<String>("contract", default: "")) { contract in
            try initialize()
            try buildContract(contractName: contract.isEmpty ? nil : "")
        }
    }
}

do {
    try main.run(ArgumentParser(arguments: Array(CommandLine.arguments.dropFirst())))
} catch let error as CLIError {
    print("Space CLI error:\n\n\(error)")
}
