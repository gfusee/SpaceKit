private let intSize: Int32 = 8

extension UInt64: TopEncode {
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        let bigEndianBytes = self.toBytes8()
        
        var startEncodingIndex: Int32 = 0
        while startEncodingIndex < intSize && accessNthElementOfBytes8(index: startEncodingIndex, bytes: bigEndianBytes) == 0 {
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
        dest.write(buffer: MXBuffer(data: self.toBytes8()))
    }
}

extension UInt64: TopDecode {
    public init(topDecode input: MXBuffer) {
        if input.count > intSize {
            smartContractError(message: "Cannot decode UInt64: input too large.")
        }
        
        let bytes = input.toBigEndianBytes8()
        
        self = toBigEndianUInt64(from: bytes)
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
        MXBuffer(data: self.toBytes8())
    }
    
}
