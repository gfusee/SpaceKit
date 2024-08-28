package func clearStorage(key: Buffer) {
    let emptyBuffer = Buffer()
    let _ = API.bufferStorageStore(keyHandle: key.handle, bufferHandle: emptyBuffer.handle)
}
