#if !WASM
public struct ABITypeStructField: Encodable {
    let name: String
    let type: String
    
    public init(name: String, type: String) {
        self.name = name
        self.type = type
    }
}
#endif
