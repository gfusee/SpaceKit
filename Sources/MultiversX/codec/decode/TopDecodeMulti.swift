public protocol TopDecodeMulti {
    init(topDecodeMulti input: inout some TopDecodeMultiInput)
}

public extension TopDecodeMulti where Self: TopDecode {
    init(topDecodeMulti input: inout some TopDecodeMultiInput) {
        self = Self(topDecode: input.nextValueInput())
    }
}
