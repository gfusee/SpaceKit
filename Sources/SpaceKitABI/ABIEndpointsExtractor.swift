#if !WASM
public protocol ABIEndpointsExtractor {
    static var _extractABIEndpoints: [ABIEndpoint] { get }
    static var _extractRequiredABITypes: [String : ABIType] { get }
}
#endif
