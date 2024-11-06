import Foundation

enum CallbackMacroError: CustomStringConvertible, Error {
    case onlyApplicableToFunc
    
    var description: String {
        switch self {
        case .onlyApplicableToFunc: return "@Callback can only be applied to a function."
        }
    }
}
