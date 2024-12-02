import Foundation

enum InitMacroError: CustomStringConvertible, Error {
    case onlyApplicableToAFunction
    case functionNameMustBeInitialize
    
    var description: String {
        switch self {
        case .onlyApplicableToAFunction: return "@Init can only be applied to a function."
        case .functionNameMustBeInitialize:
            return """
            @Init can only be applied to a function called "initialize".
            """
        }
    }
}
