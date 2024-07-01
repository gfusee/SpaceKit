// TODO: add tests for the below extensions

private let intSize: Int32 = 1

extension UInt8: TopEncode {
    @inline(__always)
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        let bigEndianBytes = [self]
        
        MXBuffer(data: bigEndianBytes)
            .topEncode(output: &output)
    }
}

extension UInt8: NestedEncode {
    @inline(__always)
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        dest.write(buffer: MXBuffer(data: [self]))
    }
}

extension UInt8: TopDecode {
    public init(topDecode input: MXBuffer) {
        let bytes: FixedArray8<UInt8> = input.toFixedSizeBytes()
        if bytes.count > intSize {
            smartContractError(message: "Cannot decode UInt8: input too large.")
        }
        
        self = UInt8(bytes.toBigEndianUInt64())
    }
}

extension UInt8: TopDecodeMulti {}

extension UInt8: NestedDecode {
    @inline(__always)
    public static func depDecode<I>(input: inout I) -> UInt8 where I : NestedDecodeInput {
        let buffer = input.readNextBuffer(length: intSize)
        
        return UInt8(topDecode: buffer)
    }
}

extension UInt8: ArrayItem {
    public static var payloadSize: Int32 {
        return 4
    }
    
    public static func decodeArrayPayload(payload: MXBuffer) -> UInt8 {
        UInt8(topDecode: payload)
    }
    
    public func intoArrayPayload() -> MXBuffer {
        var payload = MXBuffer()
        
        self.depEncode(dest: &payload)
        
        return payload
    }
    
    
}
