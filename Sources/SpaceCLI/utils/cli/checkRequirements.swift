import Foundation

func checkRequirements() async throws(CLIError) {
    let directory = URL(filePath: FileManager.default.currentDirectoryPath, directoryHint: .isDirectory)
    
    let requirements: [String] = ["clang", "git", "swift", "wasm-ld", "wasm-opt"]
    
    for requirement in requirements {
        do {
            try await runInTerminal(
                currentDirectoryURL: directory,
                command: "which \(requirement)"
            )
        } catch {
            throw .common(.requirementNotSatisfied(requirement: requirement))
        }
    }
    
}
