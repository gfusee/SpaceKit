// TODO: add tests for the below extensions

private let intSize: Int32 = 1

extension UInt8: TopEncode {
    @inline(__always)
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        MXBuffer(data: self)
            .topEncode(output: &output)
    }
}

extension UInt8: TopEncodeMulti {}

extension UInt8: NestedEncode {
    @inline(__always)
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        dest.write(buffer: MXBuffer(data: self))
    }
}

extension UInt8: TopDecode {
    public init(topDecode input: MXBuffer) {
        if input.count > intSize {
            smartContractError(message: "Cannot decode UInt8: input too large.")
        }
        
        let byte = input.toBigEndianBytes8().7
        
        self = byte
    }
}

extension UInt8: TopDecodeMulti {}

extension UInt8: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {
        let buffer = input.readNextBuffer(length: intSize)
        
        self = Self(topDecode: buffer)
    }
}

extension UInt8: ArrayItem {
    public static var payloadSize: Int32 {
        return 1
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
