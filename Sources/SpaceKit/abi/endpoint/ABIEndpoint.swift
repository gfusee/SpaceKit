#if !WASM
public struct ABIEndpoint: Encodable {
    let name: String
    let onlyOwner: Bool?
    let mutability: ABIEndpointMutability
    let payableInTokens: ABIEndpointPayableInTokens?
    let inputs: [ABIInput]
    let outputs: [ABIOutput]
}
#endif
