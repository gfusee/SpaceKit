import Foundation

enum ControllerMacroError: CustomStringConvertible, Error {
    case onlyApplicableToStruct
    case noInitAllowed
    case initAnnotatedFunctionShouldBeGlobal
    
    var description: String {
        switch self {
        case .onlyApplicableToStruct: return "@Controller can only be applied to a structure."
        case .noInitAllowed: return "No init is allowed in a structure marked @Controller."
        case .initAnnotatedFunctionShouldBeGlobal: return "@Init annotated function should be declared in the global scope."
        }
    }
}
