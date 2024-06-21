public struct BufferNestedDecodeInput {
    let buffer: MXBuffer
    var decodeIndex: Int32
    let bufferCount: Int32
    
    public init(buffer: MXBuffer) {
        let cloned = buffer.clone()
        self.buffer = cloned
        self.decodeIndex = 0
        self.bufferCount = cloned.count
    }
}

extension BufferNestedDecodeInput: NestedDecodeInput {
    public func getEntireBuffer() -> MXBuffer {
        return self.buffer.clone()
    }
    
    public mutating func readNextBuffer(length: Int32) -> MXBuffer {
        let subBuffer = self.buffer.getSubBuffer(startIndex: self.decodeIndex, length: length)
        self.decodeIndex += length
        
        return subBuffer
    }
    
    public mutating func readNextBufferOfDynamicLength() -> MXBuffer {
        let length = Int.depDecode(input: &self)
        let buffer = self.readNextBuffer(length: Int32(length)) // TODO: Use Int32.depDecode to make this cast safe
        
        return buffer
    }
    
    public func canDecodeMore() -> Bool {
        self.decodeIndex < self.bufferCount
    }
}
