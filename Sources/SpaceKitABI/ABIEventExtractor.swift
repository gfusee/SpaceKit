#if !WASM
public protocol ABIEventExtractor {
    static var _extractABIEvent: ABIEvent { get }
}
#endif
