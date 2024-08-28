public struct ArgBuffer {
    package var buffers: MXArray<MXBuffer> = MXArray()
    
    public init() {}
    
    public init(rawArgs: MXArray<MXBuffer>) {
        // push* methods are unsafe, we have to clone the rawArgs to make sure it won't be mutated later
        self.buffers = rawArgs.clone()
    }
    
    public func getRawArgs() -> MXArray<MXBuffer> {
        return self.buffers.clone()
    }
    
    public mutating func pushArg<T: TopEncodeMulti>(arg: T) {
        arg.multiEncode(output: &self)
    }
}

extension ArgBuffer: TopEncodeMultiOutput {
    public mutating func pushSingleValue<TE>(arg: TE) where TE : TopEncode {
        self.buffers.pushSingleValue(arg: arg)
    }
}
