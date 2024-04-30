public protocol StorageApiProtocol {
    mutating func bufferStorageLoad(keyHandle: Int32, bufferHandle: Int32) -> Int32
    mutating func bufferStorageStore(keyHandle: Int32, bufferHandle: Int32) -> Int32
}
