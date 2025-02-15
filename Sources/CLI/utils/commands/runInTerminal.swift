import Foundation

private actor WrappedString {
    public var string: String = ""
    
    func append(_ value: String) {
        self.string += value
    }
}

func runInTerminal(
    currentDirectoryURL: URL,
    command: String,
    environment: [String : String] = [:],
    logCommand: Bool = true
) async throws(CLIError) -> String {
    let task = Process()
    
    task.currentDirectoryURL = currentDirectoryURL
    task.launchPath = "/bin/bash"
    
    var environment = environment
    environment["PATH"] = ProcessInfo.processInfo.environment["PATH"] ?? ""
    environment["HOME"] = ProcessInfo.processInfo.environment["HOME"] ?? ""

    task.environment = environment
    task.arguments = ["-c", command]
    
    let outputPipe = Pipe()
    task.standardOutput = outputPipe
    task.standardError = outputPipe
    
    let output = WrappedString()
    
    outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
        let data = fileHandle.availableData
        if let line = String(data: data, encoding: .utf8), !line.isEmpty {
            print(line, terminator: "") // Print the output line by line
            
            Task {
                await output.append(line) // Append to the output string
            }
        }
    }
    
    CurrentTerminalProcess.process = task
    
    do {
        if logCommand {
            print("INFO: Running \(command) in \(currentDirectoryURL.path)")
        }
        try task.run()
        CurrentTerminalProcess.process = nil
    } catch {
        CurrentTerminalProcess.process = nil
        throw .common(.cannotRunCommand(command: command, directory: currentDirectoryURL.path, errorMessage: error.localizedDescription))
    }
    
    task.waitUntilExit()
    let status = task.terminationStatus
    guard status == 0 else {
        throw .common(.cannotRunCommand(command: command, directory: currentDirectoryURL.path, errorMessage: "Command exited with status code \(status)."))
    }
    
    return await output.string
}

func runInDocker(
    volumeURLs: (host: URL, dest: URL)?,
    commands: [String],
    environment: [String : String] = [:],
    arguments: [String] = [],
    showDockerLogs: Bool = true
) async throws(CLIError) -> String {
    var commandsWithInfo: [String] = []
    
    for command in commands {
        if showDockerLogs {
            commandsWithInfo.append("""
            echo "Info: Running \(command) in Docker"
            """)
        }
        
        commandsWithInfo.append(command)
    }
    
    let commandsWithInfoString = commandsWithInfo.joined(separator: "\n\n")
    let script = """
    #!/bin/zsh

    # Exit immediately if a command exits with a non-zero status
    set -e
    
    \(commandsWithInfoString)
    """
    
    let removeDockerLogsIfNeeded = if showDockerLogs {
        ""
    } else {
        " 2>/dev/null"
    }
    
    let (currentDirectoryURL, volumeArg) = if let volumeURLs = volumeURLs {
        (volumeURLs.host, " -v .:\(volumeURLs.dest.path)")
    } else {
        (
            URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true),
            ""
        )
    }
    
    let dockerImage = "ghcr.io/gfusee/spacekit-cli:0.0.14"
    
    // Try to pull the spacekit-cli docker image, but skip if:
    //
    // - The image already exists
    // - There is no internet connection
    _ = try await runInTerminal(
        currentDirectoryURL: currentDirectoryURL,
        command: """
            docker images --format "{{.Repository}}:{{.Tag}}" | grep -q '\(dockerImage)' || (ping -c 1 google.com >/dev/null 2>&1 && docker pull \(dockerImage))
            """,
        environment: environment,
        logCommand: false
    )
    
    return try await runInTerminal(
        currentDirectoryURL: currentDirectoryURL,
        command: """
                docker run --rm\(volumeArg) \(dockerImage) /bin/bash -c "echo '\(script.toBase64())'\(removeDockerLogsIfNeeded) | base64 -d | /bin/bash"
                """,
        environment: environment,
        logCommand: false
    )
}
