// TODO: use signed managed type instead of unsigned BigUint
// TODO: add tests for the below extensions

private let intSize = 8

extension UInt64 {
    func asBigEndianBytes() -> [UInt8] {
        return [
            UInt8((self >> 56) & 0xFF),
            UInt8((self >> 48) & 0xFF),
            UInt8((self >> 40) & 0xFF),
            UInt8((self >> 32) & 0xFF),
            UInt8((self >> 24) & 0xFF),
            UInt8((self >> 16) & 0xFF),
            UInt8((self >> 8) & 0xFF),
            UInt8(self & 0xFF),
        ]
    }
}

extension UInt64: TopEncode {
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        let bigEndianBytes = self.asBigEndianBytes()
        
        /*
        var startEncodingIndex = 0
        while startEncodingIndex < intSize && bigEndianBytes[startEncodingIndex] == 0 {
            startEncodingIndex += 1
        }
        
        MXBuffer(data: bigEndianBytes)
            .getSubBuffer(startIndex: startEncodingIndex, length: intSize - startEncodingIndex)
            .topEncode(output: &output)
         */
    }
}

extension UInt64: NestedEncode {
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        dest.write(buffer: MXBuffer(data: self.asBigEndianBytes()))
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
