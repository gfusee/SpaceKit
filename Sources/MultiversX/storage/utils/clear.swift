package func clearStorage(key: MXBuffer) {
    let emptyBuffer = MXBuffer()
    let _ = API.bufferStorageStore(keyHandle: key.handle, bufferHandle: emptyBuffer.handle)
}