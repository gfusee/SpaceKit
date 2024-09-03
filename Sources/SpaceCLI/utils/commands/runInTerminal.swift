import AppKit

func runInTerminal(
    currentDirectoryURL: URL,
    command: String,
    environment: [String : String] = [:],
    arguments: [String] = []
) async throws(CLIError) {
    let task = Process()
    
    task.currentDirectoryURL = currentDirectoryURL
    task.launchPath = "/bin/bash"
    
    var environment = environment
    environment["PATH"] = ProcessInfo.processInfo.environment["PATH"] ?? ""
    
    task.environment = environment
    
    let fullCommand = "\(command) \(arguments.joined(separator: " "))"
    task.arguments = ["-c", fullCommand]
    
    await CurrentTerminalProcess.process = task
    
    do {
        print("INFO: Running \(fullCommand) in \(currentDirectoryURL.path)")
        try task.run()
        await CurrentTerminalProcess.process = nil
    } catch {
        await CurrentTerminalProcess.process = nil
        fatalError() // TODO
    }
    
    task.waitUntilExit()
    let status = task.terminationStatus
    guard status == 0 else {
        fatalError() // TODO
    }
}
