import Foundation

func getPermanentStorageDirectory() throws(CLIError) -> URL {
    let fileManager = FileManager.default
    
    let cliPermanentStorageDirectory = fileManager.homeDirectoryForCurrentUser.appending(path: ".space")
    
    if !fileManager.fileExists(atPath: cliPermanentStorageDirectory.path) {
        do {
            try fileManager.createDirectory(at: cliPermanentStorageDirectory, withIntermediateDirectories: false)
        } catch {
            throw .fileManager(.cannotCreateFileOrDirectory(path: cliPermanentStorageDirectory))
        }
    }
    
    return cliPermanentStorageDirectory
}
