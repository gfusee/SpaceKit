// TODO: add tests for the below extensions

private let intSize: Int32 = 4

extension UInt32 {
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

extension UInt32: TopEncode {
    @inline(__always)
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        let bigEndianBytes = self.asBigEndianBytes()
        
        var startEncodingIndex: Int32 = 0
        while startEncodingIndex < intSize && bigEndianBytes[Int(startEncodingIndex)] == 0 {
            startEncodingIndex += 1
        }
        
        MXBuffer(data: bigEndianBytes)
            .getSubBuffer(startIndex: startEncodingIndex, length: intSize - startEncodingIndex)
            .topEncode(output: &output)
    }
}

extension UInt32: TopEncodeMulti {}

extension UInt32: NestedEncode {
    @inline(__always)
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        dest.write(buffer: MXBuffer(data: self.asBigEndianBytes()))
    }
}

extension UInt32: TopDecode {
    public init(topDecode input: MXBuffer) {
        let bytes: FixedArray8<UInt8> = input.toFixedSizeBytes()
        if input.count > intSize {
            smartContractError(message: "Cannot decode UInt64: input too large.")
        }
        
        self = UInt32(bytes.toBigEndianUInt64())
    }
}

extension UInt32: TopDecodeMulti {}

extension UInt32: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {
        let buffer = input.readNextBuffer(length: intSize)
        
        self = UInt32(topDecode: buffer)
    }
}

extension UInt32: ArrayItem {
    public static var payloadSize: Int32 {
        intSize
    }
    
    public static func decodeArrayPayload(payload: MXBuffer) -> UInt32 {
        var payloadInput = BufferNestedDecodeInput(buffer: payload)
        
        let result = UInt32(depDecode: &payloadInput)
        
        guard !payloadInput.canDecodeMore() else {
            fatalError()
        }
        
        return result
    }
    
    public func intoArrayPayload() -> MXBuffer {
        MXBuffer(data: self.asBigEndianBytes())
    }
    
}
