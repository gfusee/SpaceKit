#if !WASM
public struct ABIInput: Encodable {
    let name: String
    let type: String
}
#endif
