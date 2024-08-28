public struct CallbackClosureLoader {
    var index: Int32
    let count: Int32
    let argBuffer: ArgBuffer
    
    public init() {
        var bufferSerialized = Buffer()
        
        API.managedGetCallbackClosure(callbackClosureHandle: bufferSerialized.handle)
        
        var argBuffer = ArgBuffer()
        var nestedDecodeInput = BufferNestedDecodeInput(buffer: bufferSerialized)
        
        while nestedDecodeInput.canDecodeMore() {
            argBuffer.pushArg(arg: nestedDecodeInput.readNextBufferOfDynamicLength())
        }
        
        self.argBuffer = argBuffer
        self.index = 0
        self.count = 0
    }
}

extension CallbackClosureLoader: TopDecodeMultiInput {
    public func hasNext() -> Bool {
        self.index < self.count
    }
    
    public mutating func nextValueInput() -> Buffer {
        let buffer = self.argBuffer.buffers.get(self.index)
        
        self.index += 1
        
        return buffer
    }
    
    
}
