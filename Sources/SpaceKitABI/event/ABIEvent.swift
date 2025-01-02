#if !WASM
public struct ABIEvent: Encodable {
    let identifier: String
    let inputs: [ABIEventInput]
    
    public init(
        identifier: String,
        inputs: [ABIEventInput]
    ) {
        self.identifier = identifier
        self.inputs = inputs
    }
}
#endif
