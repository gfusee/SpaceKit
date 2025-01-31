#if !WASM
public struct ABIBuildInfoFramework: Encodable {
    let name: String
    let version: String
    
    public init(name: String, version: String) {
        self.name = name
        self.version = version
    }
}
#endif
