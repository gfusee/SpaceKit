enum ContractBuildError: Error, CustomStringConvertible {
    case cannotUseLocalSpaceKitAndOverrideHashAtTheSameTime
    case multipleContractsFound(contracts: [String])
    
    var description: String {
        switch self {
        case .cannotUseLocalSpaceKitAndOverrideHashAtTheSameTime:
            """
            --spacekit-local-path and --override-spacekit-hash cannot be used at the same time. 
            """
        case .multipleContractsFound(let contracts):
            """
            Multiple contracts found: \(contracts.split(separator: ", ")).
            
            The --contract <contract name> argument is mandatory in this case.
            """
        }
    }
}
