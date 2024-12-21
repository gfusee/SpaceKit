// TODO: add tests for the below extensions

extension Optional: TopEncode where Wrapped: NestedEncode {
    @inline(__always)
    public func topEncode<EncodeOutput>(output: inout EncodeOutput) where EncodeOutput: TopEncodeOutput {
        // We can topEncode nil as an empty buffer,
        // but we still have to append the 01 when there is a value in order to differentiate the cases
        guard self != nil else {
            output.setBuffer(buffer: Buffer())
            return
        }
        var resultNestedEncoded = Buffer()
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
    public init(topDecode input: Buffer) {
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

// TODO: add tests
extension Optional: TopEncodeMulti where Wrapped: NestedEncode & TopEncodeMulti {}

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

#if !WASM
extension Optional: ABITypeExtractor where Wrapped: ABITypeExtractor {
    public static var _abiTypeName: String {
        let wrappedTypeName = Wrapped._abiTypeName
        
        return "Option<\(wrappedTypeName)>"
    }
}
#endif
