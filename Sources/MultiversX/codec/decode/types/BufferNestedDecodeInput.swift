public struct BufferNestedDecodeInput {
    let buffer: MXBuffer
    var decodeIndex: Int
    let bufferCount: Int
    
    public init(buffer: MXBuffer) {
        let cloned = buffer.clone()
        self.buffer = cloned
        self.decodeIndex = 0
        self.bufferCount = cloned.count
    }
}

extension BufferNestedDecodeInput: NestedDecodeInput {
    public mutating func readNextBuffer(length: Int) -> MXBuffer {
        let subBuffer = self.buffer.getSubBuffer(startIndex: self.decodeIndex, length: length)
        self.decodeIndex += length
        
        return subBuffer
    }
    
    public mutating func readNextBufferOfDynamicLength() -> MXBuffer {
        let length = Int.depDecode(input: &self)
        let buffer = self.readNextBuffer(length: length)
        
        return buffer
    }
}
