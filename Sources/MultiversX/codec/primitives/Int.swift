private let intSize: Int32 = 4

extension Int {
    // This function should be inlined top avoid heap allocation
    @inline(__always) package func asBigEndianBytes() -> [UInt8] {
        return [
            UInt8((self >> 24) & 0xFF),
            UInt8((self >> 16) & 0xFF),
            UInt8((self >> 8) & 0xFF),
            UInt8(self & 0xFF),
        ]
    }
}

extension Int: TopEncode {
    @inline(__always)
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        let bigEndianBytes = self.asBigEndianBytes()
        
        let leftBytesToRemove = self >= 0 ? 0x00 : 0xFF
        
        var startEncodingIndex: Int32 = 0
        while startEncodingIndex < intSize && bigEndianBytes[Int(startEncodingIndex)] == leftBytesToRemove {
            startEncodingIndex += 1
        }
        
        MXBuffer(data: bigEndianBytes)
            .getSubBuffer(startIndex: startEncodingIndex, length: intSize - startEncodingIndex)
            .topEncode(output: &output)
    }
}

extension Int: NestedEncode {
    @inline(__always)
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        dest.write(buffer: MXBuffer(data: self.asBigEndianBytes()))
    }
}

extension Int: TopDecode {
    public init(topDecode input: MXBuffer) {
        let bytes: FixedArray8<UInt8> = input.toFixedSizeBytes()
        if bytes.count > intSize {
            smartContractError(message: "Cannot decode Int: input too large.")
        }
        
        self = bytes.toBigEndianInt()
    }
}

extension Int: TopDecodeMulti {}

extension Int: NestedDecode {
    @inline(__always)
    public static func depDecode<I>(input: inout I) -> Int where I : NestedDecodeInput {
        let buffer = input.readNextBuffer(length: intSize)
        
        return Int(topDecode: buffer)
    }
}
