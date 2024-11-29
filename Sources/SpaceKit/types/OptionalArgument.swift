public enum OptionalArgument<Wrapped: TopEncode & TopEncodeMulti & TopDecode & TopDecodeMulti & NestedEncode & NestedDecode> {
    case some(Wrapped)
    case none
}

extension OptionalArgument {
    public init(optional: Optional<Wrapped>) {
        if let value = optional {
            self = .some(value)
        } else {
            self = .none
        }
    }
    
    public func intoOptional() -> Optional<Wrapped> {
        switch self {
        case .some(let value):
            return value
        case .none:
            return nil
        }
    }
}

extension OptionalArgument: TopEncode {
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        return self.intoOptional().topEncode(output: &output)
    }
}

extension OptionalArgument: TopEncodeMulti {
    public func multiEncode<O>(output: inout O) where O : TopEncodeMultiOutput {
        // TODO: add tests
        switch self {
        case .none:
            break
        case .some(let value):
            output.pushSingleValue(arg: value)
        }
    }
}

extension OptionalArgument: NestedEncode {
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        return self.intoOptional().depEncode(dest: &dest)
    }
}

extension OptionalArgument: TopDecode {
    public init(topDecode input: Buffer) {
        self = Self(optional: Optional<Wrapped>(topDecode: input))   
    }
}

extension OptionalArgument: TopDecodeMulti {
    public init(topDecodeMulti input: inout some TopDecodeMultiInput) {
        if input.hasNext() {
            self = .some(Wrapped(topDecode: input.nextValueInput()))
        } else {
            self = .none
        }
    }
}

extension OptionalArgument: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {
        self = Self(optional: Optional<Wrapped>(depDecode: &input))   
    }
}
