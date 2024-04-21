protocol BufferApiProtocol {
    func bufferSetBytes(handle: Int32, bytePtr: UnsafePointer<UInt8>, byteLen: Int32) -> Int32
    func bufferAppend(accumulatorHandle: Int32, dataHandle: Int32) -> Int32
    func bufferFinish(handle: Int32) -> Int32
}
