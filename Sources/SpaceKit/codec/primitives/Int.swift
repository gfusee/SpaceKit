extension Int: TopEncode {
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        Int32(self).topEncode(output: &output) // TODO: check that this cast is safe
    }
}

extension Int: TopEncodeMulti {}

extension Int: NestedEncode {
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        dest.write(buffer: Buffer(data: Int32(self).toBytes4())) // TODO: check that this cast is safe
    }
}

extension Int: TopDecode {
    public init(topDecode input: Buffer) {
        self = Int(Int32(topDecode: input)) // TODO: check that this cast is safe
    }
}

extension Int: TopDecodeMulti {}

extension Int: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {
        self = Int(Int32(depDecode: &input)) // TODO: check that this cast is safe
    }
}
