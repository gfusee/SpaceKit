#if !WASM
public struct ABIBuildInfo: Encodable {
    let framework: ABIBuildInfoFramework
    
    public init(framework: ABIBuildInfoFramework) {
        self.framework = framework
    }
}
#endif
