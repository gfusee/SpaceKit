enum CommonErrors: Error, CustomStringConvertible {
    case invalidProject
    case requirementNotSatisfied(requirement: String)
    case cannotRunCommand(command: String, directory: String, errorMessage: String)
    case dockerIsNotRunning
    
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
        case .dockerIsNotRunning:
            """
            Docker is not installed or running.

            If you’re on macOS, make sure Docker Desktop is installed and running.
            If you’re on Linux or using Windows WSL, check the official Docker website for installation instructions.
            """
        }
    }
}
