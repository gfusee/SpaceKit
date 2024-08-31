import Foundation

func initialize() throws(CLIError) {
    try checkRequirements()
    
    let _ = try getPermanentStorageDirectory()
}
