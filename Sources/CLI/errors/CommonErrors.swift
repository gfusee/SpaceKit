enum CommonErrors: Error, CustomStringConvertible {
    case invalidProject
    case requirementNotSatisfied(requirement: String)
    case cannotRunCommand(command: String, directory: String, errorMessage: String)
    
    var description: String {
        switch self {
        case .invalidProject:
            "The project is invalid. A valid project is one having a \"Contracts\" folder."
        case .requirementNotSatisfied(let requirement):
            "\(requirement) is not installed on this computer or not in PATH."
        case .cannotRunCommand(let command, let directory, let errorMessage):
            """
            The command "\(command)" failed with the following error:
            
            \(errorMessage)
            
            Note : Command ran in \(directory).
            """
        }
    }
}
