#if !WASM
import SpaceKitABI
#endif

let UPGRADABLE_FLAG: UInt16 = 0b0000_0001_0000_0000
let READABLE_FLAG: UInt16 = 0b0000_0100_0000_0000
let PAYABLE_FLAG: UInt16 = 0b0000_0000_0000_0010
let PAYABLE_BY_SC_FLAG: UInt16 = 0b0000_0000_0000_0100

public struct CodeMetadata {
    var upgradable: Bool
    var readable: Bool
    var payable: Bool
    var payableBySC: Bool
    
    public init(
        upgradable: Bool,
        readable: Bool,
        payable: Bool,
        payableBySC: Bool
    ) {
        self.upgradable = upgradable
        self.readable = readable
        self.payable = payable
        self.payableBySC = payableBySC
    }
    
    public init(flag: UInt16) {
        // TODO: add tests
        self.upgradable = (flag & UPGRADABLE_FLAG) != 0
        self.readable = (flag & READABLE_FLAG) != 0
        self.payable = (flag & PAYABLE_FLAG) != 0
        self.payableBySC = (flag & PAYABLE_BY_SC_FLAG) != 0
    }
    
    func getFlag() -> UInt16 {
        // TODO: add tests
        var result: UInt16 = 0
        
        if self.upgradable {
            result |= UPGRADABLE_FLAG
        }
        
        if self.readable {
            result |= READABLE_FLAG
        }
        
        if self.payable {
            result |= PAYABLE_FLAG
        }
        
        if self.payableBySC {
            result |= PAYABLE_BY_SC_FLAG
        }
        
        return result
    }
}

extension CodeMetadata: TopEncode {
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        self.getFlag().topEncode(output: &output)
    }
}

extension CodeMetadata: TopEncodeMulti {}

extension CodeMetadata: NestedEncode {
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        self.getFlag().depEncode(dest: &dest)
    }
}

extension CodeMetadata: TopDecode {
    public init(topDecode input: Buffer) {
        self = CodeMetadata(flag: UInt16(topDecode: input))
    }
}

extension CodeMetadata: TopDecodeMulti {}

extension CodeMetadata: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {
        self = CodeMetadata(flag: UInt16(depDecode: &input))
    }
}

extension CodeMetadata: ArrayItem {
    public static var payloadSize: Int32 {
        UInt16.payloadSize
    }
    
    public static func decodeArrayPayload(payload: Buffer) -> CodeMetadata {
        return CodeMetadata(flag: UInt16.decodeArrayPayload(payload: payload))
    }
    
    public func intoArrayPayload() -> Buffer {
        return self.getFlag().intoArrayPayload()
    }
}

#if !WASM
extension CodeMetadata: ABITypeExtractor {
    public static var _abiTypeName: String {
        UInt16._abiTypeName
    }
}
#endif
