#if !WASM
public struct ABI: Encodable {
    let buildInfo: ABIBuildInfo
    let name: String
    let constructor: ABIConstructor
    let endpoints: [ABIEndpoint]
    let events: [ABIEvent]
    let types: [String : ABIType]
}
#endif
