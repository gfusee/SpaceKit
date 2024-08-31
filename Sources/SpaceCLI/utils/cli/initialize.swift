import Foundation

func initialize() throws(CLIError) {
    let fileManager = FileManager.default
    
    let _ = try getPermanentStorageDirectory()
}
