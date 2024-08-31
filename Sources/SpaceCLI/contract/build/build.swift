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
    let objectFilePath = "\(buildFolder)/\(target).o"
    let wasmBuiltFilePath = "\(buildFolder)/\(target).wasm"
    let wasmOptFilePath = "\(buildFolder)/\(target)-opt.wasm"
    let targetPackageOutputPath = "\(pwd)/Contracts/\(target)/Output"
    let wasmDestFilePath = "\(targetPackageOutputPath)/\(target).wasm"
    let scenariosJsonDir = "\(pwd)/Contracts/\(target)/Scenarios"

    let swiftBinFolder = "/Library/Developer/Toolchains/swift-6.0-DEVELOPMENT-SNAPSHOT-2024-07-16-a.xctoolchain/usr/bin" // TODO: Replace with the actual path to your Swift binary folder
    let scenarioJsonExecutable = "/Users/quentin/multiversx-sdk/vmtools/v1.5.24/mx-chain-vm-go-1.5.24/cmd/test/test" // TODO: Replace with the actual path to the scenario JSON executable

    do {
        // Explanations: we want to create a copy of the source files before compiling them.
        // This copy will be done in .space/sc-build, note that the sc-build folder is resetted at each build.
        // Only Contracts/$TARGET has to be copied.
        
        // Create .space directory
        if !fileManager.fileExists(atPath: ".space") {
            try fileManager.createDirectory(atPath: ".space", withIntermediateDirectories: true, attributes: nil)
        }
        
        // Change to .space directory
        fileManager.changeCurrentDirectoryPath(".space")
        
        // Create sc-build directory
        if !fileManager.fileExists(atPath: "sc-build") {
            try fileManager.createDirectory(atPath: "sc-build", withIntermediateDirectories: true, attributes: nil)
        }
        
        // Change to sc-build directory
        fileManager.changeCurrentDirectoryPath("sc-build")
        
        let scBuildDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
        
        let copiedTargetURL = scBuildDirectory
            .appending(path: "Contracts/\(target)")
        
        // Create the Contracts/TARGET folder
        if !fileManager.fileExists(atPath: copiedTargetURL.path) {
            try fileManager.createDirectory(at: copiedTargetURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Delete everything excepted the .build folder
        if fileManager.fileExists(atPath: scBuildDirectory.path) {
            try fileManager.removeItem(at: scBuildDirectory)
        }
        
        try fileManager.createDirectory(at: copiedTargetURL, withIntermediateDirectories: true)
        
        // Copy Contracts/$TARGET directory
        // Note: we run the cp command because we want to override while (in the future) keeping old files
        try runInTerminal(
            currentDirectoryURL: scBuildDirectory,
            command: "cp -r \(pwd)/Contracts/\(target) \(scBuildDirectory.path)/Contracts"
        )
        
        // Copy Package.swift
        // Note: we run the cp command because we want to override the previousPackage.swift
        try runInTerminal(
            currentDirectoryURL: scBuildDirectory,
            command: "cp \(pwd)/Package.swift Package.swift"
        )
        
        // Remove the .build copied folder
        let scBuildArtifactsDirectory = scBuildDirectory.appending(path: ".build")
        if fileManager.fileExists(atPath: scBuildArtifactsDirectory.path) {
            try fileManager.removeItem(at: scBuildArtifactsDirectory)
        }
        
        // Run Swift build for the current architecture
        try runInTerminal(
            currentDirectoryURL: scBuildDirectory,
            command: "\(swiftBinFolder)/swift",
            arguments: ["build", "--target", target]
        )
        
        // Run Swift build for WASM target
        try runInTerminal(
            currentDirectoryURL: scBuildDirectory,
            command: "\(swiftBinFolder)/swift",
            environment: ["SWIFT_WASM": "true"],
            arguments: [
                "build", "--target", target,
                "--triple", "wasm32-unknown-none-wasm",
                "--disable-index-store",
                "-Xswiftc", "-Osize",
                "-Xswiftc", "-gnone",
                "-Xswiftc", "-whole-module-optimization",
                "-Xswiftc", "-D", "-Xswiftc", "WASM",
                "-Xswiftc", "-disable-stack-protector",
                "-Xcc", "-fdeclspec"
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
            currentDirectoryURL: copiedTargetURL,
            command: "wasm-ld",
            arguments: wasmLdArguments
        )
        
        // Run wasm-opt
        try runInTerminal(
            currentDirectoryURL: copiedTargetURL,
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
            currentDirectoryURL: copiedTargetURL,
            command: scenarioJsonExecutable,
            arguments: [scenariosJsonDir]
        )
    } catch {
        print("error: \(error)")
    }

}
