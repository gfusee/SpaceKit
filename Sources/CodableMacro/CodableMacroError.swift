import Foundation

enum CodableMacroError: CustomStringConvertible, Error {
    case onlyApplicableToStructOrEnum
    case noInitAllowed
    case atLeastOneFieldRequired
    case allFieldsShouldHaveAType
    
    var description: String {
        switch self {
        case .onlyApplicableToStructOrEnum: return "@Codable can only be applied to a structure or an enum."
        case .noInitAllowed: return "A structure annotated with @Codable should not have an initializer."
        case .atLeastOneFieldRequired: return "A structure annotated with @Codable should have at least one field."
        case .allFieldsShouldHaveAType: return "All fields in a struct annotated with @Codable should have their type explicitly specified."
        }
    }
}
