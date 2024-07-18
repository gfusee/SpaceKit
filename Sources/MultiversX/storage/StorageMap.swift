public struct StorageMap<K: NestedEncode, V: TopEncode & TopDecode> {
    private let baseKey: MXBuffer
    
    public init(baseKey: MXBuffer) {
        self.baseKey = baseKey
    }

    public func clear(_ key: K) {
        // TODO: add tests
        clearStorage(key: self.getKey(keyItem: key))
    }

    public func isEmpty(_ key: K) -> Bool {
        // TODO: add tests
        return self.getSingleValueMapper(key: key).isEmpty()
    }
    
    private func getKey(keyItem: K) -> MXBuffer {
        var result = MXBuffer()
        keyItem.depEncode(dest: &result)
        
        return self.baseKey + result
    }
    
    private func getSingleValueMapper(key: K) -> SingleValueMapper<V> {
        return SingleValueMapper(key: self.getKey(keyItem: key))
    }
    
    public subscript(_ item: K) -> V {
        get {
            return self.getSingleValueMapper(key: item).get()
        } set {
            self.getSingleValueMapper(key: item).set(newValue)
        }
    }
    
    public subscript(ifPresent item: K) -> V? { // TODO: add tests
        get {
            let mapper = self.getSingleValueMapper(key: item)
            
            if mapper.isEmpty() {
                return nil
            } else {
                return mapper.get()
            }
        }
    }
}
