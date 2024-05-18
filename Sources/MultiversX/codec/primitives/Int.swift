// TODO: use signed managed type instead of unsigned BigUint

private let intSize = 4

extension Int: TopEncode {
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        BigUint(value: Int64(self)).topEncode(output: &output)
    }
}

extension Int: NestedEncode {
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput { // TODO: check if tests exist
        var bigEndianBuffer = MXBuffer()
        self.topEncode(output: &bigEndianBuffer)
        
        let bigEndianBufferCount = bigEndianBuffer.count
        
        let leadingZerosBuffer = MXBuffer(data: [0, 0, 0, 0])
            .getSubBuffer(startIndex: 0, length: intSize - bigEndianBufferCount)
        
        dest.write(buffer: leadingZerosBuffer + bigEndianBuffer)
    }
}

extension Int: TopDecode {
    public static func topDecode(input: MXBuffer) -> Int {
        guard let value = BigUint.topDecode(input: input).toInt64() else {
            fatalError()
        }
        
        guard value <= Int.max else {
            fatalError()
        }
        
        return Int(value)
    }
}

extension Int: TopDecodeMulti {}

extension Int: NestedDecode {
    public static func depDecode<I>(input: inout I) -> Int where I : NestedDecodeInput {
        let buffer = input.readNextBuffer(length: intSize)
        
        return Int.topDecode(input: buffer)
    }
}
