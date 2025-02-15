import Foundation
import Workspace
import Basics
import ArgumentParser

struct InitCommandOptions: ParsableArguments {
    @Argument(help: "The name of the directory which will be created.")
    var name: String
}

struct InitCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Create a new SpaceKit project in a new directory."
    )
    
    @OptionGroup var options: InitCommandOptions
    
    mutating func run() async throws {
        try await initializeProject(
            name: self.options.name
        )
    }
}

func initializeProject(
    name: String
) async throws(CLIError) {
    let fileManager = FileManager.default
    let pwd = URL(fileURLWithPath: fileManager.currentDirectoryPath)
    
    let projectPath = pwd.appending(path: name)
    
    guard !fileManager.fileExists(atPath: projectPath.path) else {
        throw .projectInit(.directoryAlreadyExists(path: pwd.path))
    }
    
    try await fetchTemplateProject(
        in: pwd,
        directoryName: name,
        commitHash: "0919f9c8d0b5e8ec0ef7d8114fb4ffdaeccea923"
    )
    
    let counterTemplateContractPath = projectPath.appending(path: "Contracts/Counter")
    let namedTemplateContractPath = projectPath.appending(path: "Contracts/\(name)")
    
    let counterTestTemplateContractPath = namedTemplateContractPath.appending(path: "Tests/CounterTests")
    let namedTestTemplateContractPath = namedTemplateContractPath.appending(path: "Tests/\(name)Tests")
    
    do {
        try fileManager.moveItem(at: counterTemplateContractPath, to: namedTemplateContractPath)
    }
    catch {
        throw .fileManager(.cannotMoveFileOrDirectory(at: counterTemplateContractPath, to: namedTemplateContractPath))
    }
    
    do {
        try fileManager.moveItem(at: counterTestTemplateContractPath, to: namedTestTemplateContractPath)
    }
    catch {
        throw .fileManager(.cannotMoveFileOrDirectory(at: counterTestTemplateContractPath, to: namedTestTemplateContractPath))
    }
    
    let gitDirectoryPath = projectPath.appending(path: ".git")
    do {
        try fileManager.removeItem(at: gitDirectoryPath)
    } catch {
        throw .fileManager(.cannotRemoveFileOrDirectory(path: gitDirectoryPath))
    }
    
    let templateFilesPaths = [
        projectPath.appending(path: "Package.swift"),
        namedTestTemplateContractPath.appending(path: "CounterTests.swift")
    ]
    
    for templateFilePath in templateFilesPaths {
        guard let templateFileContent = fileManager.contents(atPath: templateFilePath.path) else {
            throw .projectInit(.cannotReadFile(path: templateFilePath.path))
        }

        guard var templateFileContent = String(data: templateFileContent, encoding: .utf8) else {
            throw .projectInit(.cannotDecodePackageSwiftUsingUTF8(path: templateFilePath.path))
        }
        
        templateFileContent = templateFileContent
            .replacingOccurrences(of: "##PACKAGE_NAME##", with: name)
            .replacingOccurrences(of: "##TARGET_NAME##", with: name)
        
        fileManager.createFile(atPath: templateFilePath.path, contents: templateFileContent.data(using: .utf8))
    }
}
