#if !WASM
public protocol ABIEndpointsExtractor {
    static func extractABIEndpoints() -> [ABIEndpoint]
}
#endif
