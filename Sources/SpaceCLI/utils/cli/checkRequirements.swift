import Foundation

func checkRequirements() throws(CLIError) {
    let directory = URL(filePath: FileManager.default.currentDirectoryPath, directoryHint: .isDirectory)
    
    let requirements: [String] = ["clang", "git", "swift", "wasm-ld", "wasm-opt"]
    
    for requirement in requirements {
        do {
            try runInTerminal(
                currentDirectoryURL: directory,
                command: "which \(requirement)"
            )
        } catch {
            throw .common(.requirementNotSatisfied(requirement: requirement))
        }
    }
    
}
