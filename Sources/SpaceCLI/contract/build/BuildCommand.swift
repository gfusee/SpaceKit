import Foundation
import Workspace
import Basics
import ArgumentParser

struct BuildCommandOptions: ParsableArguments {
    @Option(help: "The contract's name to build.")
    var contract: String? = nil
    
    @Option(help: "The path to a custom swift toolchain.")
    var customSwiftToolchain: String? = nil
}

struct BuildCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Build a contract to a .wasm file",
        aliases: ["build"]
    )
    
    @OptionGroup var options: BuildCommandOptions
    
    mutating func run() async throws {
        try await buildContract(
            contractName: self.options.contract,
            customSwiftToolchain: self.options.customSwiftToolchain
        )
    }
}

// TODO: remove relative path, this is not safe
func buildContract(
    contractName: String?,
    customSwiftToolchain: String?
) async throws(CLIError) {
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
    let pwd = fileManager.currentDirectoryPath
    
    let linkableObjects = (try await buildLinkableObjects())
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

    let swiftCommand = if let customSwiftToolchain = customSwiftToolchain {
        "\(customSwiftToolchain)/swift"
    } else {
        "swift"
    }

    do {
        // Explanations: we want to create a symbolic link of the source files before compiling them.
        // By doing so, we avoid generating *.o files in the user project root directory
        
        if fileManager.fileExists(atPath: contractsUrl.path) {
            try fileManager.removeItem(at: contractsUrl)
        }
        
        try fileManager.createDirectory(at: contractsUrl, withIntermediateDirectories: true)
        
        // Create the Contracts/TARGET symbolic link
        try await runInTerminal(
            currentDirectoryURL: buildFolderUrl,
            command: "ln -sf \(sourceTargetPath) \(linkedTargetUrl.path)"
        )
        
        let newPackagePath = "\(buildFolder)/Package.swift"
        if fileManager.fileExists(atPath: newPackagePath) {
            try fileManager.removeItem(at: URL(filePath: newPackagePath))
        }
        
        // Add the custom Package.swift dedicated to WASM compilation
        fileManager.createFile(
            atPath: newPackagePath,
            contents: (try generateWASMPackage(sourcePackagePath: pwd, target: target)).data(using: .utf8)
        )
        
        // Run Swift build for WASM target
        try await runInTerminal(
            currentDirectoryURL: buildFolderUrl,
            command: swiftCommand,
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
        try await runInTerminal(
            currentDirectoryURL: buildFolderUrl,
            command: "wasm-ld",
            arguments: wasmLdArguments
        )
        
        // Run wasm-opt
        try await runInTerminal(
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
        
        print(
            """
            \(target) built successfully!
            WAMS output: \(wasmDestFilePath)
            """
        )
    } catch {
        print("error: \(error)")
    }
}
