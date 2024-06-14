private let intSize = 4

extension Int {
    // This function should be inlined top avoid heap allocation
    @inline(__always) func asBigEndianBytes() -> [UInt8] {
        return [
            UInt8((self >> 24) & 0xFF),
            UInt8((self >> 16) & 0xFF),
            UInt8((self >> 8) & 0xFF),
            UInt8(self & 0xFF),
        ]
    }
}

extension Int: TopEncode {
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        let bigEndianBytes = self.asBigEndianBytes()
        
        let leftBytesToRemove = self >= 0 ? 0x00 : 0xFF
        
        var startEncodingIndex = 0
        while startEncodingIndex < intSize && bigEndianBytes[startEncodingIndex] == leftBytesToRemove {
            startEncodingIndex += 1
        }
        
        MXBuffer(data: bigEndianBytes)
            .getSubBuffer(startIndex: startEncodingIndex, length: intSize - startEncodingIndex)
            .topEncode(output: &output)
    }
}

extension Int: NestedEncode {
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        dest.write(buffer: MXBuffer(data: self.asBigEndianBytes()))
    }
}

extension Int: TopDecode {
    public static func topDecode(input: MXBuffer) -> Int {
        let bytes: FixedArray8<UInt8> = input.toFixedSizeBytes()
        if bytes.count > intSize {
            smartContractError(message: "Cannot decode Int: input too large.")
        }
        
        return bytes.toBigEndianInt()
    }
}

extension Int: TopDecodeMulti {}

extension Int: NestedDecode {
    public static func depDecode<I>(input: inout I) -> Int where I : NestedDecodeInput {
        let buffer = input.readNextBuffer(length: intSize)
        
        return Int.topDecode(input: buffer)
    }
}
