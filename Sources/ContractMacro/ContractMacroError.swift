import Foundation

enum ContractMacroError: CustomStringConvertible, Error {
    case onlyApplicableToStruct
    case onlyOneInitAllowed
    
    var description: String {
        switch self {
        case .onlyApplicableToStruct: return "@Contract can only be applied to a structure."
        case .onlyOneInitAllowed: return "Only one or zero initializer is allowed in a structure marked @Contract."
        }
    }
}
