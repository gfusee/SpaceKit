import Foundation

enum ControllerMacroError: CustomStringConvertible, Error {
    case onlyApplicableToStruct
    case noInitAllowed
    case initAnnotatedFunctionShouldBeGlobal
    case shouldBePublic
    
    var description: String {
        switch self {
        case .onlyApplicableToStruct: return "@Controller can only be applied to a structure."
        case .noInitAllowed: return "No init is allowed in a structure marked @Controller."
        case .initAnnotatedFunctionShouldBeGlobal: return "@Init annotated function should be declared in the global scope."
        case .shouldBePublic: return "A structure annotated @Controller should be public."
        }
    }
}
