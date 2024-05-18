public protocol NestedDecodeInput {
    /// Used for types with known length: Int8, Int16, etc.
    mutating func readNextBuffer(length: Int) -> MXBuffer
    
    /// Used for types with dynamic length, that have their size encoded along with their data.
    /// Example: MXBuffer, BigUint, etc.
    mutating func readNextBufferOfDynamicLength() -> MXBuffer
}
