public protocol NestedDecodeInput {
    /// Returns the entire original buffer, without consuming it.
    /// - Warning: You should cloning the returned buffer (or creating a new one), as it could be mutated afterwards.
    func getEntireBuffer() -> MXBuffer
    
    /// Used for types with known length: Int8, Int16, etc.
    mutating func readNextBuffer(length: Int) -> MXBuffer
    
    /// Used for types with dynamic length, that have their size encoded along with their data.
    /// Example: MXBuffer, BigUint, etc.
    mutating func readNextBufferOfDynamicLength() -> MXBuffer
    
    func canDecodeMore() -> Bool
}
