#if !WASM
public protocol ABITypeExtractor {
    static var _abiTypeName: String { get }
    static var _extractABIType: ABIType? { get }
    static var _isMulti: Bool { get }
}

extension ABITypeExtractor {
    public static var _extractABIType: ABIType? {
        nil
    }
    
    public static var _isMulti: Bool {
        false
    }
}
#endif
