public protocol TopDecodeMulti {
    init(topDecodeMulti input: inout some TopDecodeMultiInput)
}

public extension TopDecodeMulti where Self: TopDecode {
    @inline(__always)
    init(topDecodeMulti input: inout some TopDecodeMultiInput) {
        self = Self(topDecode: input.nextValueInput())
    }
}
