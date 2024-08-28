public struct IgnoreValue {
    public init() {}
}

extension IgnoreValue: TopEncode {
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {}
}

extension IgnoreValue: TopEncodeMulti {
    public func multiEncode<O>(output: inout O) where O : TopEncodeMultiOutput {}
}

extension IgnoreValue: NestedEncode {
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {}
}

extension IgnoreValue: TopDecode {
    public init(topDecode input: Buffer) {}
}

extension IgnoreValue: TopDecodeMulti {
    public init(topDecodeMulti input: inout some TopDecodeMultiInput) {}
}

extension IgnoreValue: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {}
}
