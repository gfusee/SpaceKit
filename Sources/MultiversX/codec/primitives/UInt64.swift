private let intSize: Int32 = 8

extension UInt64 {
    // This function should be inlined top avoid heap allocation
    @inline(__always) func asBigEndianBytes() -> Bytes8 {
        return (
            UInt8((self >> 56) & 0xFF),
            UInt8((self >> 48) & 0xFF),
            UInt8((self >> 40) & 0xFF),
            UInt8((self >> 32) & 0xFF),
            UInt8((self >> 24) & 0xFF),
            UInt8((self >> 16) & 0xFF),
            UInt8((self >> 8) & 0xFF),
            UInt8(self & 0xFF)
        )
    }
}

extension UInt64: TopEncode {
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        let bigEndianBytes = self.asBigEndianBytes()
        var bigEndianBytesArray = FixedArray8<UInt8>(count: Int(intSize))
        
        bigEndianBytesArray[0] = bigEndianBytes.0
        bigEndianBytesArray[1] = bigEndianBytes.1
        bigEndianBytesArray[2] = bigEndianBytes.2
        bigEndianBytesArray[3] = bigEndianBytes.3
        bigEndianBytesArray[4] = bigEndianBytes.4
        bigEndianBytesArray[5] = bigEndianBytes.5
        bigEndianBytesArray[6] = bigEndianBytes.6
        bigEndianBytesArray[7] = bigEndianBytes.7
        
        var startEncodingIndex: Int32 = 0
        while startEncodingIndex < intSize && bigEndianBytesArray[Int(startEncodingIndex)] == 0 {
            startEncodingIndex += 1
        }
        
        MXBuffer(data: bigEndianBytes)
            .getSubBuffer(startIndex: startEncodingIndex, length: intSize - startEncodingIndex)
            .topEncode(output: &output)
    }
}

extension UInt64: TopEncodeMulti {}

extension UInt64: NestedEncode {
    @inline(__always)
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        dest.write(buffer: MXBuffer(data: self.asBigEndianBytes()))
    }
}

extension UInt64: TopDecode {
    public init(topDecode input: MXBuffer) {
        let bytes: FixedArray8<UInt8> = input.toFixedSizeBytes()
        if input.count > intSize {
            smartContractError(message: "Cannot decode UInt64: input too large.")
        }
        
        self = bytes.toBigEndianUInt64()
    }
}

extension UInt64: TopDecodeMulti {}

extension UInt64: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {
        let buffer = input.readNextBuffer(length: intSize)
        
        self = UInt64(topDecode: buffer)
    }
}

extension UInt64: ArrayItem {
    public static var payloadSize: Int32 {
        intSize
    }
    
    public static func decodeArrayPayload(payload: MXBuffer) -> UInt64 {
        var payloadInput = BufferNestedDecodeInput(buffer: payload)
        
        let result = UInt64(depDecode: &payloadInput)
        
        guard !payloadInput.canDecodeMore() else {
            fatalError()
        }
        
        return result
    }
    
    public func intoArrayPayload() -> MXBuffer {
        MXBuffer(data: self.asBigEndianBytes())
    }
    
}
