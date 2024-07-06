// TODO: add tests for the below extensions

@Codable fileprivate enum OptionalEnum<T: MXCodable> {
    case none
    case some(T)
}

fileprivate extension OptionalEnum {
    init(optional: Optional<T>) {
        if let value = optional {
            self = .some(value)
        } else {
            self = .none
        }
    }
    
    func intoOptional() -> Optional<T> {
        switch self {
        case .some(let value):
            return value
        case .none:
            return nil
        }
    }
}

extension Optional: TopEncode where Wrapped: MXCodable {
    @inline(__always)
    public func topEncode<EncodeOutput>(output: inout EncodeOutput) where EncodeOutput: TopEncodeOutput {
        if self == nil {
            MXBuffer().topEncode(output: &output)
        } else {
            OptionalEnum(optional: self).topEncode(output: &output)
        }
    }
}

extension Optional: NestedEncode where Wrapped: MXCodable {
    @inline(__always)
    public func depEncode<O>(dest: inout O) where O: NestedEncodeOutput {
        OptionalEnum(optional: self).depEncode(dest: &dest)
    }
}

extension Optional: TopDecode where Wrapped: MXCodable {
    public init(topDecode input: MXBuffer) {
        if input.count == 0 {
            self = nil
        } else {
            self = OptionalEnum<Wrapped>(topDecode: input).intoOptional()
        }
    }
}

extension Optional: TopDecodeMulti where Wrapped: MXCodable {
    @inline(__always)
    public static func topDecodeMulti<T>(input: inout T) -> Optional<Wrapped> where T: TopDecodeMultiInput {
        return OptionalEnum<Wrapped>(topDecodeMulti: &input).intoOptional()
    }
}

extension Optional: NestedDecode where Wrapped: MXCodable {
    public init(depDecode input: inout some NestedDecodeInput) {
        self = OptionalEnum<Wrapped>(depDecode: &input).intoOptional()
    }
}
