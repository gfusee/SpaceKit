private let intSize: Int32 = 4

extension Int32: TopEncode {
    @inline(__always)
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        let bigEndianBytes = self.toBytes4()
        
        let leftBytesToRemove = self >= 0 ? 0x00 : 0xFF
        
        var startEncodingIndex: Int32 = 0
        
        while startEncodingIndex < intSize && accessNthElementOfBytes4(index: startEncodingIndex, bytes: bigEndianBytes) == leftBytesToRemove {
            startEncodingIndex += 1
        }
        
        Buffer(data: bigEndianBytes)
            .getSubBuffer(startIndex: startEncodingIndex, length: intSize - startEncodingIndex)
            .topEncode(output: &output)
    }
}

extension Int32: TopEncodeMulti {}

extension Int32: NestedEncode {
    @inline(__always)
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        dest.write(buffer: Buffer(data: self.toBytes4()))
    }
}

extension Int32: TopDecode {
    public init(topDecode input: Buffer) {
        let count = input.count
        if count > intSize {
            smartContractError(message: "Cannot decode Int: input too large.")
        }
        
        let bytes8 = input.toBigEndianBytes8()
        let bytes4 = toBytes4BigEndian(bytes8: bytes8)
        
        self = toBigEndianInt32(skipZerosCount: 4 - count, from: bytes4)
    }
}

extension Int32: TopDecodeMulti {}

extension Int32: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {
        let buffer = input.readNextBuffer(length: intSize)
        
        self = Int32(topDecode: buffer)
    }
}

#if !WASM
extension Int32: ABITypeExtractor {
    public static var _abiTypeName: String {
        "i32"
    }
}
#endif
