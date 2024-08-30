/*
 #!/bin/zsh

 set -e

 SWIFT_BIN_FOLDER="/Library/Developer/Toolchains/swift-6.0-DEVELOPMENT-SNAPSHOT-2024-07-16-a.xctoolchain/usr/bin/"
 SCENARIO_JSON_EXECUTABLE="/Users/quentin/multiversx-sdk/vmtools/v1.5.24/mx-chain-vm-go-1.5.24/cmd/test/test"

 TARGET="Adder"

 # Do not edit the below variables
 BUILD_FOLDER="$(pwd)/.space/sc-build"
 OBJECT_FILE_PATH="$BUILD_FOLDER/$TARGET.o"
 MEMCPY_OBJECT_FILE_PATH="/Users/quentin/IdeaProjects/mx-sdk-swift/Utils/Memory/memcpy.o"
 MULTI3_OBJECT_FILE_PATH="/Users/quentin/IdeaProjects/mx-sdk-swift/Utils/Numbers/__multi3.o"
 WASM_BUILT_FILE_PATH="$BUILD_FOLDER/$TARGET.wasm"
 WASM_OPT_FILE_PATH="$BUILD_FOLDER/$TARGET-opt.wasm"
 TARGET_PACKAGE_OUTPUT_PATH="$(pwd)/Output"
 WASM_DEST_FILE_PATH="$TARGET_PACKAGE_OUTPUT_PATH/$TARGET.wasm"
 SCENARIOS_JSON_DIR="$(pwd)/Scenarios"

 mkdir -p .space
 cd .space
 rm -rf sc-build
 mkdir -p sc-build
 cd sc-build

 cp -f -R ../../Sources Sources
 cp -f ../../Package.swift Package.swift
 [ -d "../../Tests" ] && cp -f -R ../../Tests Tests

 # This will emit macros build results for the current computer's architecture
 # Those macros results are needed despite we will compile later for WASM
 $SWIFT_BIN_FOLDER/swift build --target $TARGET

 SWIFT_WASM=true $SWIFT_BIN_FOLDER/swift build --target $TARGET --triple wasm32-unknown-none-wasm --disable-index-store -Xswiftc -Osize -Xswiftc -gnone -Xswiftc -whole-module-optimization -Xswiftc -D -Xswiftc WASM -Xswiftc -disable-stack-protector -Xcc -fdeclspec

 wasm-ld --no-entry --allow-undefined $OBJECT_FILE_PATH "$MEMCPY_OBJECT_FILE_PATH" "$MULTI3_OBJECT_FILE_PATH" -o $WASM_BUILT_FILE_PATH
 wasm-opt -Os -o $WASM_OPT_FILE_PATH $WASM_BUILT_FILE_PATH

 mkdir -p $TARGET_PACKAGE_OUTPUT_PATH
 cp -f $WASM_OPT_FILE_PATH $WASM_DEST_FILE_PATH

 $SCENARIO_JSON_EXECUTABLE $SCENARIOS_JSON_DIR
 */

import Foundation

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
    
    let buildFolder = "\(pwd)/.space/sc-build"
    let objectFilePath = "\(buildFolder)/\(target).o"
    let memcpyObjectFilePath = "/Users/quentin/IdeaProjects/mx-sdk-swift/Utils/Memory/memcpy.o" // TODO: compile and set
    let multi3ObjectFilePath = "/Users/quentin/IdeaProjects/mx-sdk-swift/Utils/Numbers/__multi3.o" // TODO: compile and set
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
        
        // Remove sc-build directory if it exists
        if fileManager.fileExists(atPath: "sc-build") {
            try fileManager.removeItem(atPath: "sc-build")
        }
        
        // Create sc-build directory
        try fileManager.createDirectory(atPath: "sc-build", withIntermediateDirectories: true, attributes: nil)
        
        // Change to sc-build directory
        fileManager.changeCurrentDirectoryPath("sc-build")
        
        // Create the Contracts folder
        try fileManager.createDirectory(atPath: "Contracts", withIntermediateDirectories: true, attributes: nil)
        
        // Copy Contracts/$TARGET directory
        try fileManager.copyItem(atPath: "\(pwd)/Contracts/\(target)", toPath: "Contracts/\(target)")
        
        // Copy Package.swift
        try fileManager.copyItem(atPath: "\(pwd)/Package.swift", toPath: "Package.swift")
        
        let copiedTargetPath = fileManager.currentDirectoryPath
        let copiedTargetURL = URL(filePath: copiedTargetPath, directoryHint: .isDirectory)
        
        // Run Swift build for the current architecture
        try runInTerminal(
            currentDirectoryURL: copiedTargetURL,
            command: "\(swiftBinFolder)/swift",
            arguments: ["build", "--target", target]
        )
        
        // Run Swift build for WASM target
        try runInTerminal(
            currentDirectoryURL: copiedTargetURL,
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
        
        // Run wasm-ld
        try runInTerminal(
            currentDirectoryURL: copiedTargetURL,
            command: "wasm-ld",
            arguments: [
                "--no-entry", "--allow-undefined",
                objectFilePath, memcpyObjectFilePath, multi3ObjectFilePath,
                "-o", wasmBuiltFilePath
            ]
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
