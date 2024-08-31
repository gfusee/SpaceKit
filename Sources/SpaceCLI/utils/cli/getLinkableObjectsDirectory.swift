import Foundation

func getLinkableObjectsDirectory() throws(CLIError) -> URL {
    let fileManager = FileManager.default
    let linkableObjectsDirectory = (try getPermanentStorageDirectory()).appending(path: "objects")
    
    if !fileManager.fileExists(atPath: linkableObjectsDirectory.path) {
        do {
            try fileManager.createDirectory(at: linkableObjectsDirectory, withIntermediateDirectories: false)
        } catch {
            throw .fileManager(.cannotCreateFileOrDirectory(path: linkableObjectsDirectory))
        }
    }
    
    return linkableObjectsDirectory
}
