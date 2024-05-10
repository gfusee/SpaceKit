public protocol TopDecodeMulti {
    static func topDecodeMulti<T: TopDecodeMultiInput>(input: inout T) -> Self
}

public extension TopDecodeMulti where Self: TopDecode {
    static func topDecodeMulti<T: TopDecodeMultiInput>(input: inout T) -> Self {
        Self.topDecode(input: input.nextValueInput())
    }
}
