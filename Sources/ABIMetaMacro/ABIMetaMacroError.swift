import Foundation

enum ABIMetaMacroError: CustomStringConvertible, Error {
    case onlyApplicableToStruct
    case noMemberAllowed
    case pathsShouldBeStringLiterals
    case cannotDecodeSymbolGraph
    case noABIConstructorExtractorSymbolFound
    case noABIEndpointsExtractorSymbolFound
    case noABITypeExtractorSymbolFound
    case noABIEventExtractorSymbolFound
    case noGraphJSONContentsArgumentProvided
    case noSpaceKitGraphJSONContentArgumentProvided
    case cannotEncodeStringToUTF8Data
    
    var description: String {
        switch self {
        case .onlyApplicableToStruct: return "@ABIMeta can only be applied to a structure."
        case .noMemberAllowed: return "A structure annotated with @ABIMeta should be empty."
        case .pathsShouldBeStringLiterals: return "The paths argument of @ABIMeta should be an array of string literals."
        case .cannotDecodeSymbolGraph: return "Cannot decode as SymbolGraph."
        case .noABIConstructorExtractorSymbolFound: return "Protocol ABIConstructorExtractor not found in SpaceKit's symbol graph."
        case .noABIEndpointsExtractorSymbolFound: return "Protocol ABIEndpointsExtractor not found in SpaceKit's symbol graph."
        case .noABITypeExtractorSymbolFound: return "Protocol ABITypeExtractor not found in SpaceKit's symbol graph."
        case .noABIEventExtractorSymbolFound: return "Protocol ABIEventExtractor not found in SpaceKit's symbol graph."
        case .noGraphJSONContentsArgumentProvided: return "\"graphJSONContents\" parameter is missing."
        case .noSpaceKitGraphJSONContentArgumentProvided: return "\"spaceKitGraphJSONContent\" parameter is missing."
        case .cannotEncodeStringToUTF8Data: return "Cannot encode String to UTF-8 Data."
        }
    }
}
