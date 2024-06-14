// TODO: add tests for the below extensions

private let intSize = 1

extension UInt8: TopEncode {
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        let bigEndianBytes = [self]
        
        MXBuffer(data: bigEndianBytes)
            .topEncode(output: &output)
    }
}

extension UInt8: NestedEncode {
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        dest.write(buffer: MXBuffer(data: [self]))
    }
}

extension UInt8: TopDecode {
    public static func topDecode(input: MXBuffer) -> UInt8 {
        let bytes: FixedArray8<UInt8> = input.toFixedSizeBytes()
        if bytes.count > intSize {
            smartContractError(message: "Cannot decode UInt8: input too large.")
        }
        
        return UInt8(bytes.toBigEndianUInt64())
    }
}

extension UInt8: TopDecodeMulti {}

extension UInt8: NestedDecode {
    public static func depDecode<I>(input: inout I) -> UInt8 where I : NestedDecodeInput {
        let buffer = input.readNextBuffer(length: intSize)
        
        return UInt8.topDecode(input: buffer)
    }
}
