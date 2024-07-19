import Foundation

enum EventMacroError: CustomStringConvertible, Error {
    case onlyApplicableToStruct
    case noInitAllowed
    case allFieldsShouldHaveAType
    
    var description: String {
        switch self {
        case .onlyApplicableToStruct: return "@Event can only be applied to a structure."
        case .noInitAllowed: return "A structure annotated with @Event should not have an initializer."
        case .allFieldsShouldHaveAType: return "All fields in a struct annotated with @Event should have their type explicitly specified."
        }
    }
}
