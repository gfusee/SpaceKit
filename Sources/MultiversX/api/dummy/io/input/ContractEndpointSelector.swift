#if !WASM
public protocol ContractEndpointSelector {
    mutating func _callEndpoint(name: String)
}
#endif
