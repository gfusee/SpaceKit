import Foundation

func isValidProject() throws(CLIError) -> Bool {
    let fileManager = FileManager.default
    
    let currentDirectoryString = fileManager.currentDirectoryPath
    guard let currentDirectory = URL(string: currentDirectoryString) else {
        throw .fileManager(.cannotConvertCurrentDirectoryStringAsURL(currentDirectory: currentDirectoryString))
    }
    
    let subDirectories: [URL]
    do {
        subDirectories = try fileManager.contentsOfDirectory(
            at: currentDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
            .filter(\.hasDirectoryPath)
    } catch {
        throw .fileManager(.cannotReadContentsOfDirectory(at: currentDirectory))
    }
    
    var isContractsDirectoryPresent = false
    
    for directory in subDirectories {
        if directory.lastPathComponent == "Contracts" {
            isContractsDirectoryPresent = true
            break
        }
    }
    
    return isContractsDirectoryPresent
}
