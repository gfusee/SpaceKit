public struct StorageMap<K: NestedEncode, V: TopEncode & TopDecode> {
    private let baseKey: Buffer
    
    public init(baseKey: Buffer) {
        self.baseKey = baseKey
    }

    public func clear(_ key: K) {
        // TODO: add tests
        clearStorage(key: self.getKey(keyItem: key))
    }

    public func isEmpty(_ key: K) -> Bool {
        // TODO: add tests
        return self.getSingleValueMapper(baseKey: key).isEmpty()
    }
    
    private func getKey(keyItem: K) -> Buffer {
        var result = Buffer()
        keyItem.depEncode(dest: &result)
        
        return self.baseKey + result
    }
    
    private func getSingleValueMapper(baseKey: K) -> SingleValueMapper<V> {
        return SingleValueMapper(baseKey: self.getKey(keyItem: baseKey))
    }
    
    public subscript(_ item: K) -> V {
        get {
            return self.getSingleValueMapper(baseKey: item).get()
        } set {
            self.getSingleValueMapper(baseKey: item).set(newValue)
        }
    }
    
    public subscript(ifPresent item: K) -> V? { // TODO: add tests
        get {
            let mapper = self.getSingleValueMapper(baseKey: item)
            
            if mapper.isEmpty() {
                return nil
            } else {
                return mapper.get()
            }
        }
    }
}
