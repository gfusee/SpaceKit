public protocol BufferApiProtocol {
    mutating func bufferSetBytes(handle: Int32, bytePtr: UnsafeRawPointer, byteLen: Int32) -> Int32
    
    mutating func mBufferSetByteSlice(
        mBufferHandle: Int32,
        startingPosition: Int32,
        dataLength: Int32,
        dataOffset: UnsafeRawPointer
    ) -> Int32
    
    mutating func mBufferAppendBytes(accumulatorHandle: Int32, byte_ptr: UnsafeRawPointer, byte_len: Int32) -> Int32
    
    mutating func bufferCopyByteSlice(
        sourceHandle: Int32,
        startingPosition: Int32,
        sliceLength: Int32,
        destinationHandle: Int32
    ) -> Int32
    
    mutating func bufferAppend(accumulatorHandle: Int32, dataHandle: Int32) -> Int32
    mutating func bufferFinish(handle: Int32) -> Int32
    mutating func bufferFromBigIntUnsigned(bufferHandle: Int32, bigIntHandle: Int32) -> Int32
    mutating func bufferToBigIntUnsigned(bufferHandle: Int32, bigIntHandle: Int32) -> Int32
    mutating func bufferEqual(handle1: Int32, handle2: Int32) -> Int32
    
    mutating func managedBufferToHex(sourceHandle: Int32, destinationHandle: Int32)
    
    mutating func mBufferSetRandom(destinationHandle: Int32, length: Int32) -> Int32
    
    mutating func validateTokenIdentifier(tokenIdHandle: Int32) -> Int32
    
    #if !WASM
    mutating func bufferToDebugString(handle: Int32) -> String
    mutating func bufferToUTF8String(handle: Int32) -> String?
    #endif
}
