import Foundation

fileprivate struct ObjectFileInfo {
    let filename: String
    let directory: URL
    let outputName: String
}

func buildLinkableObjects() async throws(CLIError) -> [URL] {
    let spaceRepoUrl = "/Users/quentin/IdeaProjects/space"
    let spaceRepoName = "SpaceFramework"
    
    let permanentStorageDirectory = try getPermanentStorageDirectory()
    let spaceRepoPath = permanentStorageDirectory.appending(path: spaceRepoName)
    
    let fileManager = FileManager.default
    
    if fileManager.fileExists(atPath: spaceRepoPath.path) {
        do {
            try fileManager.removeItem(at: spaceRepoPath)
        } catch {
            throw .fileManager(.cannotRemoveFileOrDirectory(path: spaceRepoPath))
        }
    }
    
    // We clone the framework and name the "SpaceFramework" for convenience
    try await runInTerminal(
        currentDirectoryURL: permanentStorageDirectory,
        command: "git clone \(spaceRepoUrl) \(spaceRepoName)"
    )
    
    let allObjectFileInfo = [
        ObjectFileInfo(
            filename: "memcpy.c",
            directory: spaceRepoPath.appending(path: "Utils/Memory"),
            outputName: "memcpy.o"
        ),
        ObjectFileInfo(
            filename: "__multi3.c",
            directory: spaceRepoPath.appending(path: "Utils/Numbers"),
            outputName: "__multi3.o"
        )
    ]
    
    let outputDirectory = try getLinkableObjectsDirectory()
    var resultFilePaths: [URL] = []
    
    for objectFileInfo in allObjectFileInfo {
        try await runInTerminal(
            currentDirectoryURL: objectFileInfo.directory,
            command: "clang --target=wasm32 -O3 -c -o \(objectFileInfo.outputName) \(objectFileInfo.filename)"
        )
        
        let outputFilePath = outputDirectory.appending(path: objectFileInfo.outputName)
        if fileManager.fileExists(atPath: outputFilePath.path) {
            do {
                try fileManager.removeItem(at: outputFilePath)
            } catch {
                throw .fileManager(.cannotRemoveFileOrDirectory(path: outputFilePath))
            }
        }
        
        let compiledObjectPath = objectFileInfo.directory.appending(path: objectFileInfo.outputName)
        
        do {
            try fileManager.copyItem(at: compiledObjectPath, to: outputFilePath)
        } catch {
            print(error)
            throw .fileManager(.cannotCopyFileOrDirectory(at: compiledObjectPath, to: outputFilePath))
        }
        
        resultFilePaths.append(outputFilePath)
    }
    
    return resultFilePaths
}
