// TODO: use signed managed type instead of unsigned BigUint
// TODO: add tests for the below extensions

private let intSize = 8

extension UInt64: TopEncode {
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        BigUint(value: Int64(self)).topEncode(output: &output) // TODO: overflow!!! See root todo
    }
}

extension UInt64: NestedEncode {
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        var bigEndianBuffer = MXBuffer()
        self.topEncode(output: &bigEndianBuffer)
        
        let bigEndianBufferCount = bigEndianBuffer.count
        
        let leadingZerosBuffer = MXBuffer(data: [0, 0, 0, 0, 0, 0, 0, 0])
            .getSubBuffer(startIndex: 0, length: intSize - bigEndianBufferCount)
        
        dest.write(buffer: leadingZerosBuffer + bigEndianBuffer)
    }
}

extension UInt64: TopDecode {
    public static func topDecode(input: MXBuffer) -> UInt64 {
        guard let value = BigUint.topDecode(input: input).toInt64() else { // TODO: overflow!!! See above todo
            fatalError()
        }
        
        guard value <= Int.max else {
            fatalError()
        }
        
        return UInt64(value)
    }
}

extension UInt64: TopDecodeMulti {}

extension UInt64: NestedDecode {
    public static func depDecode<I>(input: inout I) -> UInt64 where I : NestedDecodeInput {
        let buffer = input.readNextBuffer(length: intSize)
        
        return UInt64.topDecode(input: buffer)
    }
}
