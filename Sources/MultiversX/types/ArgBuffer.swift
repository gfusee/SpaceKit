public struct ArgBuffer {
    package var buffers: MXArray<MXBuffer> = MXArray()
    
    public init() {}
    
    public mutating func pushArg<T: TopEncodeMulti>(arg: T) {
        arg.multiEncode(output: &self)
    }
}

extension ArgBuffer: TopEncodeMultiOutput {
    public mutating func pushSingleValue<TE>(arg: TE) where TE : TopEncode {
        var buffer = MXBuffer()
        arg.topEncode(output: &buffer)
        
        self.buffers = self.buffers.appended(buffer)
    }
}
