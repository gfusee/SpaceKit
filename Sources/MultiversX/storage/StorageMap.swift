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
    
    private func loadStorageBuffer(key: K) -> MXBuffer {
        let storedValueBufferHandle = getNextHandle()
        let _ = API.bufferStorageLoad(keyHandle: self.getKey(keyItem: key).handle, bufferHandle: storedValueBufferHandle)
        
        return MXBuffer(handle: storedValueBufferHandle)
    }
    
    public subscript(_ item: K) -> V {
        get {
            return V(topDecode: self.loadStorageBuffer(key: item))
        } set {
            var output = MXBuffer()
            newValue.topEncode(output: &output)
            let _ = API.bufferStorageStore(keyHandle: self.getKey(keyItem: item).handle, bufferHandle: output.handle)
        }
    }
    
    public subscript(ifPresent item: K) -> V? { // TODO: add tests
        get {
            let buffer = self.loadStorageBuffer(key: item)
            
            if buffer.count == 0 {
                return nil
            } else {
                return V(topDecode: self.loadStorageBuffer(key: item))
            }
        }
    }
    
    public subscript(isEmpty item: K) -> Bool { // TODO: add tests
        get {
            return self.loadStorageBuffer(key: item).count == 0
        }
    }
}
