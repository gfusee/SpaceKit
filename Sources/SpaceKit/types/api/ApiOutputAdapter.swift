public struct ApiOutputAdapter {
    public init() {}
}

extension ApiOutputAdapter: TopEncodeOutput {
    public mutating func setBuffer(buffer: Buffer) {
        let _ = API.bufferFinish(handle: buffer.handle) // TODO: handle error?
    }
}

extension ApiOutputAdapter: TopEncodeMultiOutput {
    public mutating func pushSingleValue<TE>(arg: TE) where TE : TopEncode {
        arg.topEncode(output: &self)
    }
}
