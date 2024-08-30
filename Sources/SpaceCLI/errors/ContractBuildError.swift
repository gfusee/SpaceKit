enum ContractBuildError: Error, CustomStringConvertible {
    case multipleContractsFound(contracts: [String])
    
    var description: String {
        switch self {
        case .multipleContractsFound(let contracts):
            """
            Multiple contracts found: \(contracts.split(separator: ", ")).
            
            The --contract <contract name> argument is mandatory in this case.
            """
        }
    }
}
