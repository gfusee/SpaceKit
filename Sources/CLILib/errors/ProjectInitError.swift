enum ProjectInitError: Error, CustomStringConvertible {
    case directoryAlreadyExists(path: String)
    case cannotReadFile(path: String)
    case cannotDecodePackageSwiftUsingUTF8(path: String)
    
    var description: String {
        switch self {
        case .directoryAlreadyExists(let path):
            """
            The directory \(path) already exists.
            """
        case .cannotReadFile(let path):
            """
            Cannot read the fetched temlate file: \(path).
            """
        case .cannotDecodePackageSwiftUsingUTF8(let path):
            """
            Cannot decode the fetched \(path) template to an UTF8 String.
            """
        }
    }
}
