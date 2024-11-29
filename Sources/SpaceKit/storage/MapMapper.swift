fileprivate let MAPPED_VALUE_IDENTIFIER: StaticString = ".mapped"

public struct MapMapper<K: TopEncode & NestedEncode & TopDecode, V: TopEncode & NestedEncode & TopDecode> {
    // TODO: add tests
    private let baseKey: Buffer
    private let keysSetMapper: SetMapper<K>
    
    public init(baseKey: Buffer) {
        self.baseKey = baseKey
        self.keysSetMapper = SetMapper(baseKey: baseKey)
    }
    
    private func buildNamedKey(name: Buffer, key: K) -> Buffer {
        var keyNestedEncoded = Buffer()
        key.depEncode(dest: &keyNestedEncoded)
        
        return self.baseKey + name + keyNestedEncoded
    }
    
    private func getMappedValueMapper(key: K) -> SingleValueMapper<V> {
        return SingleValueMapper(baseKey: self.buildNamedKey(name: Buffer(stringLiteral: MAPPED_VALUE_IDENTIFIER), key: key))
    }
    
    public func get(_ key: K) -> V? {
        guard self.keysSetMapper.contains(value: key) else {
            return nil
        }
        
        return self.getMappedValueMapper(key: key).get()
    }
    
    public func insert(key: K, value: V) -> V? {
        let oldValue = self.get(key)
        self.getMappedValueMapper(key: key).set(value)
        let _ = self.keysSetMapper.insert(value: key)
        
        return oldValue
    }
    
    public func remove(key: K) -> V? {
        if self.keysSetMapper.remove(value: key) {
            let valueMapper = self.getMappedValueMapper(key: key)
            let value = valueMapper.get()
            valueMapper.clear()
            return value
        }
        
        return nil
    }
    
    public func clear() {
        self.keysSetMapper.forEach { key in
            self.getMappedValueMapper(key: key).clear()
        }
        
        self.keysSetMapper.clear()
    }
    
    public func forEach(_ operations: (K, V) throws -> Void) rethrows {
        try self.keysSetMapper.forEach { key in
            let value = self.getMappedValueMapper(key: key).get()
            
            try operations(key, value)
        }
    }
}
