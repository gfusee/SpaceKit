public struct BufferNestedDecodeInput {
    let buffer: Buffer
    var decodeIndex: Int32
    public let bufferCount: Int32
    
    public init(buffer: Buffer) {
        let cloned = buffer.clone()
        self.buffer = cloned
        self.decodeIndex = 0
        self.bufferCount = cloned.count
    }
}

extension BufferNestedDecodeInput: NestedDecodeInput {
    public func getEntireBuffer() -> Buffer {
        return self.buffer.clone()
    }
    
    public mutating func readNextBuffer(length: Int32) -> Buffer {
        let subBuffer = self.buffer.getSubBuffer(startIndex: self.decodeIndex, length: length)
        self.decodeIndex += length
        
        return subBuffer
    }
    
    public mutating func readNextBufferOfDynamicLength() -> Buffer {
        let length = Int32(depDecode: &self)
        let buffer = self.readNextBuffer(length: length)
        
        return buffer
    }
    
    public func canDecodeMore() -> Bool {
        self.decodeIndex < self.bufferCount
    }
}
