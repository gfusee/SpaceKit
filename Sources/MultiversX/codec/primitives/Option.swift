// TODO: add tests for the below extensions

extension Optional: TopEncode where Wrapped: NestedEncode {
    @inline(__always)
    public func topEncode<EncodeOutput>(output: inout EncodeOutput) where EncodeOutput: TopEncodeOutput {
        var resultNestedEncoded = MXBuffer()
        self.depEncode(dest: &resultNestedEncoded)
        
        output.setBuffer(buffer: resultNestedEncoded)
    }
}

extension Optional: NestedEncode where Wrapped: NestedEncode {
    @inline(__always)
    public func depEncode<O>(dest: inout O) where O: NestedEncodeOutput {
        if let self = self {
            UInt8(1).depEncode(dest: &dest)
            self.depEncode(dest: &dest)
        } else {
            UInt8(0).depEncode(dest: &dest)
        }
    }
}

extension Optional: TopDecode where Wrapped: NestedDecode {
    public init(topDecode input: MXBuffer) {
        guard !input.isEmpty else {
            self = .none
            return
        }
        
        var nestedDecodeInput = BufferNestedDecodeInput(buffer: input)
        
        defer {
            require(
                !nestedDecodeInput.canDecodeMore(),
                "Top decode error for Optional: input too large."
             )
        }
        
        self = Optional(depDecode: &nestedDecodeInput)
    }
}

extension Optional: TopDecodeMulti where Wrapped: NestedDecode & TopDecodeMulti {}

extension Optional: NestedDecode where Wrapped: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {
        let discriminant = UInt8(depDecode: &input)
        
        if discriminant == 0 {
            self = .none
        } else if discriminant == 1 {
            self = .some(Wrapped(depDecode: &input))
        } else {
            smartContractError(message: "Cannot decode Optional value: wrong discriminant")
        }
    }
}
