#if !WASM
public protocol ABITypeExtractor {
    static var _abiTypeName: String { get }
    static var _extractABIType: ABIType? { get }
}

extension ABITypeExtractor {
    public static var _extractABIType: ABIType? {
        nil
    }
}
#endif
