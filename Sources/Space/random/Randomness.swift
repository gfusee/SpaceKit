public struct Randomness {
    public var buffer = Buffer()
    
    public mutating func nextUInt8() -> UInt8 {
        // TODO: add tests
        self.buffer.setRandomUnsafe(length: 1)
        let bytes8 = self.buffer.toBigEndianBytes8()
        
        return bytes8.7
    }
    
    // [min, max)
    public mutating func nextUInt8InRange(min: UInt8, max: UInt8) -> UInt8 {
        let random = self.nextUInt8()
        
        return min + random % (max - min)
    }
    
    public mutating func nextUInt32() -> UInt32 {
        // TODO: add tests
        self.buffer.setRandomUnsafe(length: 4)
        let bytes8 = self.buffer.toBigEndianBytes8()
        
        let bytes = toBytes4BigEndian(bytes8: bytes8)
        
        return toBigEndianUInt32(from: bytes)
    }
    
    // [min, max)
    public mutating func nextUInt32InRange(min: UInt32, max: UInt32) -> UInt32 {
        let random = self.nextUInt32()
        
        return min + random % (max - min)
    }
    
    public mutating func nextUInt64() -> UInt64 {
        // TODO: add tests
        self.buffer.setRandomUnsafe(length: 8)
        let bytes8 = self.buffer.toBigEndianBytes8()
        
        return toBigEndianUInt64(from: bytes8)
    }
    
    // [min, max)
    public mutating func nextUInt64InRange(min: UInt64, max: UInt64) -> UInt64 {
        let random = self.nextUInt64()
        
        return min + random % (max - min)
    }
}
