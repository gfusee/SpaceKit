import Foundation

enum FileManagerError: Error, CustomStringConvertible {
    case cannotConvertCurrentDirectoryStringAsURL(currentDirectory: String)
    case cannotReadContentsOfDirectory(at: URL)
    case cannotCreateFileOrDirectory(path: URL)
    case cannotRemoveFileOrDirectory(path: URL)
    case cannotCopyFileOrDirectory(at: URL, to: URL)
    
    var description: String {
        switch self {
        case .cannotReadContentsOfDirectory(let atUrl):
            """
            Cannot read the contents of the following directory: \(atUrl.path)
            """
        case .cannotConvertCurrentDirectoryStringAsURL(let currentDirectory):
            """
            The current directory path: \(currentDirectory) cannot be converted to an URL object.
            """
        case .cannotCreateFileOrDirectory(let path):
            """
            Cannot create a file or a directory at the following path: \(path.path)
            """
        case .cannotRemoveFileOrDirectory(let path):
            """
            Cannot remove a file or a directory at the following path: \(path.path)
            """
        case .cannotCopyFileOrDirectory(let at, let to):
            """
            Cannot copy \(at.path) to \(to.path)
            """
        }
    }
}
