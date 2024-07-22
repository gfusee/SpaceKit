import Foundation

enum ProxyMacroError: CustomStringConvertible, Error {
    case onlyApplicableToEnum
    case noEnumInheritenceOrRawValueAllowed
    
    var description: String {
        switch self {
        case .onlyApplicableToEnum: return "@Proxy can only be applied to an enum."
        case .noEnumInheritenceOrRawValueAllowed: return "An enumeration annotated with @Proxy should neither inherit unknown protocols nor have raw values."
        }
    }
}
