// TODO: add tests for the below extensions

@Codable fileprivate enum OptionalEnum<T: MXCodable> {
    case some(T)
    case none
}

/// OptionalEnum<T>.topDecodeMulti doesn't compile in embedded Swift, this struct is a workaround
@Codable fileprivate enum OptionalEnumBuffer {
    case some(MXBuffer)
    case none
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
    public func topEncode<T>(output: inout T) where T: TopEncodeOutput {
        OptionalEnum(optional: self).topEncode(output: &output)
    }
}

extension Optional: NestedEncode where Wrapped: MXCodable {
    public func depEncode<O>(dest: inout O) where O: NestedEncodeOutput {
        OptionalEnum(optional: self).depEncode(dest: &dest)
    }
}

extension Optional: TopDecode where Wrapped: MXCodable {
    public static func topDecode(input: MXBuffer) -> Optional<Wrapped> {
        return OptionalEnum<Wrapped>.topDecode(input: input).intoOptional()
    }
}

extension Optional: TopDecodeMulti where Wrapped: MXCodable {
    public static func topDecodeMulti<T>(input: inout T) -> Optional<Wrapped> where T: TopDecodeMultiInput {
        return OptionalEnum<Wrapped>.topDecodeMulti(input: &input).intoOptional()
    }
}

extension Optional: NestedDecode where Wrapped: MXCodable {
    public static func depDecode<I>(input: inout I) -> Optional<Wrapped> where I : NestedDecodeInput {
        return OptionalEnum<Wrapped>.depDecode(input: &input).intoOptional()
    }
}
