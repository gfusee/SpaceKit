public struct SingleValueMapperMap<K: NestedEncode, V: TopEncode & TopDecode> {
    private let baseKey: MXBuffer
    
    public init(baseKey: MXBuffer) {
        self.baseKey = baseKey
    }
    
    private func getKey(keyItem: K) -> MXBuffer {
        var result = MXBuffer()
        keyItem.depEncode(dest: &result)
        
        return self.baseKey + result
    }
    
    private func getSingleValueMapper(key: K) -> SingleValueMapper<V> {
        return SingleValueMapper(key: self.getKey(keyItem: key))
    }
    
    public subscript(_ item: K) -> SingleValueMapper<V> {
        get {
            return self.getSingleValueMapper(key: item)
        }
    }
}
