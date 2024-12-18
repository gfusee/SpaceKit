#if !WASM
public struct ABIBuildInfoFramework: Encodable {
    let name: String
    let version: String
}
#endif
