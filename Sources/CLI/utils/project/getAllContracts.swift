import Foundation

func getAllContractsNames() throws(CLIError) -> [String] {
    let fileManager = FileManager.default
    
    let currentDirectoryString = fileManager.currentDirectoryPath
    guard let currentDirectory = URL(string: currentDirectoryString) else {
        throw .fileManager(.cannotConvertCurrentDirectoryStringAsURL(currentDirectory: currentDirectoryString))
    }
    
    let contractDirectory = currentDirectory.appending(path: "Contracts")
    
    let subDirectories: [URL]
    do {
        subDirectories = try fileManager.contentsOfDirectory(
            at: contractDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
            .filter(\.hasDirectoryPath)
    } catch {
        throw .fileManager(.cannotReadContentsOfDirectory(at: currentDirectory))
    }
    
    let contracts = subDirectories.map { directory in
        return directory.lastPathComponent
    }
    
    return contracts
}
