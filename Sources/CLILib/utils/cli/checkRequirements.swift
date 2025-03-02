import Foundation

func checkRequirements() async throws(CLIError) {
    let directory = URL(filePath: FileManager.default.currentDirectoryPath, directoryHint: .isDirectory)
    
    let requirements: [String] = ["docker", "git"]
    
    for requirement in requirements {
        do {
            _ = try await runInTerminal(
                currentDirectoryURL: directory,
                command: "which \(requirement)"
            )
        } catch {
            throw .common(.requirementNotSatisfied(requirement: requirement))
        }
    }
    
}
