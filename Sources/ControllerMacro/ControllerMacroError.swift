import Foundation

enum ControllerMacroError: CustomStringConvertible, Error {
    case onlyApplicableToStruct
    case noInitAllowed
    case initAnnotatedFunctionShouldBeGlobal
    case shouldBePublic
    case multiValueEncodedShouldBeTheLastParameter(endpointName: String)
    case onlyOptionalArgumentOrMultiValueEncodedAllowed(endpointName: String)
    
    var description: String {
        switch self {
        case .onlyApplicableToStruct: return "@Controller can only be applied to a structure."
        case .noInitAllowed: return "No init is allowed in a structure marked @Controller."
        case .initAnnotatedFunctionShouldBeGlobal: return "@Init annotated function should be declared in the global scope."
        case .shouldBePublic: return "A structure annotated @Controller should be public."
        case .multiValueEncodedShouldBeTheLastParameter(let endpointName): return "\(endpointName): MultiValueEncoded should be the last parameter of an endpoint."
        case .onlyOptionalArgumentOrMultiValueEncodedAllowed(let endpointName): return "\(endpointName): Only OptionalArgument or MultiValueEncoded endpoint parameter types are allowed after an OptionalArgument parameter."
        }
    }
}
