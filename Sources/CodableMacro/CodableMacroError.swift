import Foundation

enum CodableMacroError: CustomStringConvertible, Error {
    case onlyApplicableToStructOrEnum
    case noInitAllowed
    case shouldNotHaveGenericParameter
    case atLeastOneFieldRequired
    case allFieldsShouldHaveAType
    case atLeastOneCaseRequired
    case tooManyEnumCases
    case enumShouldBeEquatable
    case noEnumInheritenceOrRawValueAllowed
    case enumAssociatedValuesShouldNotBeNamed
    
    var description: String {
        switch self {
        case .onlyApplicableToStructOrEnum: return "@Codable can only be applied to a structure or an enum."
        case .noInitAllowed: return "A structure annotated with @Codable should not have an initializer."
        case .shouldNotHaveGenericParameter: return "A struct or enum annotated with @Codable should not have any generic parameter."
        case .atLeastOneFieldRequired: return "A structure annotated with @Codable should have at least one field."
        case .allFieldsShouldHaveAType: return "All fields in a struct annotated with @Codable should have their type explicitly specified."
        case .atLeastOneCaseRequired: return "An enumeration annotated with @Codable should have at least one case."
        case .enumShouldBeEquatable: return "An enumeration annotated with @Codable should implement Equatable."
        case .noEnumInheritenceOrRawValueAllowed: return "An enumeration annotated with @Codable should neither inherit unknown protocols nor have raw values.\n\nHowever, you have to inherit the following protocol: Equatable."
        case .tooManyEnumCases: return "An enumeration annotated with @Codable should have at maximum 255 cases."
        case .enumAssociatedValuesShouldNotBeNamed: return "Associated values in an enumeration annotated with @Codable should not be named. For example, `case myCase(String)` is valid while `case myCase(value: String)` is not."
        }
    }
}
