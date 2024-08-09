public struct CallbackClosureLoader {
    var index: Int32
    let count: Int32
    let argBuffer: ArgBuffer
    
    init() {
        var argBuffer = ArgBuffer()
        
        API.managedGetCallbackClosure(callbackClosureHandle: argBuffer.buffers.buffer.handle)
        
        self.argBuffer = argBuffer
        self.index = 0
        self.count = 0
    }
}

extension CallbackClosureLoader: TopDecodeMultiInput {
    public func hasNext() -> Bool {
        self.index < self.count
    }
    
    public mutating func nextValueInput() -> MXBuffer {
        let buffer = self.argBuffer.buffers.get(self.index)
        
        self.index += 1
        
        return buffer
    }
    
    
}
