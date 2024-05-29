import Foundation

enum CodableMacroError: CustomStringConvertible, Error {
    case onlyApplicableToStructOrEnum
    case noInitAllowed
    case atLeastOneFieldRequired
    case allFieldsShouldHaveAType
    case atLeastOneCaseRequired
    case tooManyEnumCases
    case noEnumInheritenceOrRawValueAllowed
    
    var description: String {
        switch self {
        case .onlyApplicableToStructOrEnum: return "@Codable can only be applied to a structure or an enum."
        case .noInitAllowed: return "A structure annotated with @Codable should not have an initializer."
        case .atLeastOneFieldRequired: return "A structure annotated with @Codable should have at least one field."
        case .allFieldsShouldHaveAType: return "All fields in a struct annotated with @Codable should have their type explicitly specified."
        case .atLeastOneCaseRequired: return "An enumeration annotated with @Codable should have at least one case."
        case .noEnumInheritenceOrRawValueAllowed: return "An enumeration annotated with @Codable should neither inherit any protocol nor have raw values."
        case .tooManyEnumCases: return "An enumeration annotated with @Codable should have at maximum 255 cases."
        }
    }
}
