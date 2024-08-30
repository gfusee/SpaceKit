enum CommonErrors: Error, CustomStringConvertible {
    case invalidProject
    
    var description: String {
        switch self {
        case .invalidProject:
            "The project is invalid. A valid project is one having a \"Contracts\" folder."
        }
    }
}
