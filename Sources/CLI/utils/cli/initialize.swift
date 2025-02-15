import Foundation

func initialize() async throws(CLIError) {
    try await checkRequirements()
    
    let _ = try getPermanentStorageDirectory()
}
