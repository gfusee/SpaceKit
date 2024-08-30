import Foundation

enum FileManagerError: Error, CustomStringConvertible {
    case cannotConvertCurrentDirectoryStringAsURL(currentDirectory: String)
    case cannotReadContentsOfDirectory(at: URL)
    
    var description: String {
        switch self {
        case .cannotReadContentsOfDirectory(let atUrl):
            """
            Cannot read the contents of the following directory: \(atUrl.absoluteString)
            """
        case .cannotConvertCurrentDirectoryStringAsURL(let currentDirectory):
            """
            The current directory path: \(currentDirectory) cannot be converted to an URL object.
            """
        }
    }
}
