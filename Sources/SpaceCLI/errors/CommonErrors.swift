enum CommonErrors: Error, CustomStringConvertible {
    case invalidProject
    case requirementNotSatisfied(requirement: String)
    
    var description: String {
        switch self {
        case .invalidProject:
            "The project is invalid. A valid project is one having a \"Contracts\" folder."
        case .requirementNotSatisfied(let requirement):
            "\(requirement) is not installed on this computer or not in PATH."
        }
    }
}
