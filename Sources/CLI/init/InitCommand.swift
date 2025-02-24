import Foundation
import Workspace
import Basics
import ArgumentParser

struct InitCommandOptions: ParsableArguments {
    @Argument(help: "The name of the directory which will be created.")
    var name: String
    
    @Option(help: "The path to a local SpaceKit git repo.")
    var spacekitLocalPath: String? = nil
}

struct InitCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Create a new SpaceKit project in a new directory."
    )
    
    @OptionGroup var options: InitCommandOptions
    
    mutating func run() async throws {
        try await initializeProject(
            name: self.options.name,
            spacekitLocalPath: self.options.spacekitLocalPath
        )
    }
}

func initializeProject(
    name: String,
    spacekitLocalPath: String?,
    spaceKitVersion: String = spaceKitVersion
) async throws(CLIError) {
    let fileManager = FileManager.default
    let pwd = URL(fileURLWithPath: fileManager.currentDirectoryPath)
    
    let projectPath = pwd.appending(path: name)
    
    guard !fileManager.fileExists(atPath: projectPath.path) else {
        throw .projectInit(.directoryAlreadyExists(path: pwd.path))
    }
    
    let repoLocation: TemplateProjectRepoLocation = if let spacekitLocalPath = spacekitLocalPath {
        .local(path: spacekitLocalPath)
    } else {
        .remote(version: spaceKitVersion)
    }
    
    try await fetchTemplateProject(
        in: pwd,
        directoryName: name,
        repoLocation: repoLocation
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
            .replacingOccurrences(of: "##SPACEKIT_VERSION##", with: spaceKitVersion)
        
        fileManager.createFile(atPath: templateFilePath.path, contents: templateFileContent.data(using: .utf8))
    }
}
