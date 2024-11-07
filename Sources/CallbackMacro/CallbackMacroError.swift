import Foundation

enum CallbackMacroError: CustomStringConvertible, Error {
    case onlyApplicableToFunc
    case shouldBePublic
    
    var description: String {
        switch self {
        case .onlyApplicableToFunc: return "@Callback can only be applied to a function."
        case .shouldBePublic: return "The function on which @Callback is applied should be public."
        }
    }
}
