#if !WASM
public protocol ABIEndpointsExtractor {
    static var _extractABIEndpoints: [ABIEndpoint] { get }
}
#endif
