enum CLIError: Error, CustomStringConvertible {
    case common(CommonErrors)
    case contractBuild(ContractBuildError)
    case fileManager(FileManagerError)
    
    var description: String {
        switch self {
        case .common(let error):
            error.description
        case .contractBuild(let error):
            error.description
        case .fileManager(let error):
            error.description
        }
    }
}
