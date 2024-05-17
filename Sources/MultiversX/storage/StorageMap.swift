public struct StorageMap<K: TopEncode, V: TopEncode & TopDecode> {
    private let baseKey: MXBuffer
    
    public init(baseKey: MXBuffer) {
        self.baseKey = baseKey
    }
    
    private func getKey(keyItem: K) -> MXBuffer {
        var result = MXBuffer()
        keyItem.topEncode(output: &result)
        
        return self.baseKey + result
    }
    
    public subscript(_ item: K) -> V {
        get {
            let storedValueBufferHandle = getNextHandle()
            let _ = API.bufferStorageLoad(keyHandle: self.getKey(keyItem: item).handle, bufferHandle: storedValueBufferHandle)
            return V.topDecode(input: MXBuffer(handle: storedValueBufferHandle))
        } set {
            var output = MXBuffer()
            newValue.topEncode(output: &output)
            let _ = API.bufferStorageStore(keyHandle: self.getKey(keyItem: item).handle, bufferHandle: output.handle)
        }
    }
}
