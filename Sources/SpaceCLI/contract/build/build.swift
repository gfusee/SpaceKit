import Foundation

// TODO: remove relative path, this is not safe
func buildContract(contractName: String?) throws(CLIError) {
    guard try isValidProject() else {
        throw .common(.invalidProject)
    }
    
    let allContracts = try getAllContractsNames()
    
    let target: String
    if let contractName = contractName {
        fatalError() // TODO
    } else {
        guard allContracts.count == 1 else {
            throw .contractBuild(.multipleContractsFound(contracts: allContracts))
        }
        
        target = allContracts[0]
    }
    
    let fileManager = FileManager.default
    fileManager.changeCurrentDirectoryPath(INITIAL_PWD)
    let pwd = fileManager.currentDirectoryPath
    
    let linkableObjects = (try buildLinkableObjects())
        .map { $0.path }
    
    let buildFolder = "\(pwd)/.space/sc-build"
    let buildFolderUrl = URL(fileURLWithPath: buildFolder, isDirectory: true)
    let sourceTargetPath = "\(pwd)/Contracts/\(target)"
    let contractsUrl = buildFolderUrl.appending(path: "Contracts")
    let linkedTargetUrl = contractsUrl
        .appending(path: target)
    
    let objectFilePath = "\(buildFolder)/\(target).o"
    let wasmBuiltFilePath = "\(buildFolder)/\(target).wasm"
    let wasmOptFilePath = "\(buildFolder)/\(target)-opt.wasm"
    let targetPackageOutputPath = "\(pwd)/Contracts/\(target)/Output"
    let wasmDestFilePath = "\(targetPackageOutputPath)/\(target).wasm"
    let scenariosJsonDir = "\(pwd)/Contracts/\(target)/Scenarios"

    let swiftBinFolder = "/Library/Developer/Toolchains/swift-6.0-DEVELOPMENT-SNAPSHOT-2024-07-16-a.xctoolchain/usr/bin" // TODO: Replace with the actual path to your Swift binary folder
    let scenarioJsonExecutable = "/Users/quentin/multiversx-sdk/vmtools/v1.5.24/mx-chain-vm-go-1.5.24/cmd/test/test" // TODO: Replace with the actual path to the scenario JSON executable

    do {
        // Explanations: we want to create a symbolic link of the source files before compiling them.
        // By doing so, we avoid generating *.o files in the user project root directory
        
        if fileManager.fileExists(atPath: contractsUrl.path) {
            try fileManager.removeItem(at: contractsUrl)
        }
        
        try fileManager.createDirectory(at: contractsUrl, withIntermediateDirectories: true)
        
        // Create the Contracts/TARGET symbolic link
        try runInTerminal(
            currentDirectoryURL: buildFolderUrl,
            command: "ln -sf \(sourceTargetPath) \(linkedTargetUrl.path)"
        )
        
        // Create the Package.swift symbolic link
        try runInTerminal(
            currentDirectoryURL: buildFolderUrl,
            command: "ln -sf \(pwd)/Package.swift Package.swift"
        )
        
        // Run Swift build for WASM target
        try runInTerminal(
            currentDirectoryURL: buildFolderUrl,
            command: "\(swiftBinFolder)/swift",
            environment: ["SWIFT_WASM": "true"],
            arguments: [
                "build", "--target", target,
                "--triple", "wasm32-unknown-none-wasm",
                "--disable-index-store",
                "-Xswiftc", "-Osize",
                "-Xswiftc", "-gnone"
            ]
        )
        
        var wasmLdArguments = [
            "--no-entry", "--allow-undefined",
            "-o", wasmBuiltFilePath,
            objectFilePath
        ]
        
        for linkableObject in linkableObjects {
            wasmLdArguments.append(linkableObject)
        }
        
        // Run wasm-ld
        try runInTerminal(
            currentDirectoryURL: buildFolderUrl,
            command: "wasm-ld",
            arguments: wasmLdArguments
        )
        
        // Run wasm-opt
        try runInTerminal(
            currentDirectoryURL: buildFolderUrl,
            command: "wasm-opt",
            arguments: ["-Os", "-o", wasmOptFilePath, wasmBuiltFilePath]
        )
        
        // Create target package output directory
        try fileManager.createDirectory(atPath: targetPackageOutputPath, withIntermediateDirectories: true, attributes: nil)
        
        // Create the Output directory if needed
        if !fileManager.fileExists(atPath: targetPackageOutputPath) {
            try fileManager.createDirectory(atPath: targetPackageOutputPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Remove any previously built .wasm
        if fileManager.fileExists(atPath: wasmDestFilePath) {
            try fileManager.removeItem(atPath: wasmDestFilePath)
        }
        
        // Copy optimized WASM file to the destination
        try fileManager.copyItem(atPath: wasmOptFilePath, toPath: wasmDestFilePath)
        
        // Execute the scenario JSON executable
        try runInTerminal(
            currentDirectoryURL: buildFolderUrl,
            command: scenarioJsonExecutable,
            arguments: [scenariosJsonDir]
        )
    } catch {
        print("error: \(error)")
    }

}
