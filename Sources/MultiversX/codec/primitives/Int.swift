// TODO: use signed managed type instead of unsigned BigUint

extension Int: TopEncode {
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        BigUint(value: Int64(self)).topEncode(output: &output)
    }
}

extension Int: NestedEncode {
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        var bigEndianBuffer = MXBuffer()
        self.topEncode(output: &bigEndianBuffer)
        
        let bigEndianBufferCount = bigEndianBuffer.count
        
        let intSize = 4
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
