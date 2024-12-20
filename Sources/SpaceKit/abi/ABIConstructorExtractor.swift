#if !WASM
public protocol ABIConstructorExtractor {
    static var _extractABIConstructor: ABIConstructor { get }
}
#endif
