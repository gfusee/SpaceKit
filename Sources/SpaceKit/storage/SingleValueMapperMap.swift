public struct SingleValueMapperMap<K: NestedEncode, V: TopEncode & TopDecode> {
    private let baseKey: Buffer
    
    public init(baseKey: Buffer) {
        self.baseKey = baseKey
    }
    
    private func getKey(keyItem: K) -> Buffer {
        var result = Buffer()
        keyItem.depEncode(dest: &result)
        
        return self.baseKey + result
    }
    
    private func getSingleValueMapper(baseKey: K) -> SingleValueMapper<V> {
        return SingleValueMapper(baseKey: self.getKey(keyItem: baseKey))
    }
    
    public subscript(_ item: K) -> SingleValueMapper<V> {
        get {
            return self.getSingleValueMapper(baseKey: item)
        }
    }
}
