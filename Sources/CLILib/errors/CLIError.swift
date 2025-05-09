enum CLIError: Error, CustomStringConvertible {
    case common(CommonErrors)
    case contractBuild(ContractBuildError)
    case report(ReportError)
    case fileManager(FileManagerError)
    case manifest(ManifestError)
    case projectInit(ProjectInitError)
    
    var description: String {
        switch self {
        case .common(let error):
            error.description
        case .contractBuild(let error):
            error.description
        case .report(let error):
            error.description
        case .fileManager(let error):
            error.description
        case .manifest(let error):
            error.description
        case .projectInit(let error):
            error.description
        }
    }
}
