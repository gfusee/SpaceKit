import Foundation

func checkIfDockerIsRunning() async throws(CLIError) {
    let directory = URL(filePath: FileManager.default.currentDirectoryPath, directoryHint: .isDirectory)
    
    do {
        _ = try await runInTerminal(
            currentDirectoryURL: directory,
            command: "docker info > /dev/null 2>&1",
            logCommand: false
        )
    } catch {
        throw .common(.dockerIsNotRunning)
    }
}
