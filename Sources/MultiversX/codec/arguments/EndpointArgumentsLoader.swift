public struct EndpointArgumentsLoader {
    let numArguments: Int32
    private(set) var currentIndex: Int32 = 0
    
    public init() {
        self.numArguments = API.getNumArguments()
    }
}

extension EndpointArgumentsLoader: TopDecodeMultiInput {
    public func hasNext() -> Bool {
        self.numArguments > self.currentIndex + 1
    }
    
    public mutating func nextValueInput() -> MXBuffer {
        let bufferHandle = getNextHandle()
        let _ = API.bufferGetArgument(argId: self.currentIndex, bufferHandle: bufferHandle)
        
        self.currentIndex += 1
        
        return MXBuffer(handle: bufferHandle)
    }
}
