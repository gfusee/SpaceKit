#if !WASM
public enum ABIEndpointMutability: String, Codable {
    case readonly
    case mutable
}
#endif
