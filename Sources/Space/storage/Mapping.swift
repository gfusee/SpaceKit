@propertyWrapper public struct Mapping<K: NestedEncode, T: TopEncode & TopDecode> {
    
    private let key: Buffer
    
    public var wrappedValue: StorageMap<K, T> {
        get {
            StorageMap(baseKey: self.key)
        } set {
            
        }
    }
    
    public var projectedValue: SingleValueMapperMap<K, T> {
        SingleValueMapperMap(baseKey: self.key)
    }
    
    public init(
        key: Buffer
    ) {
        self.key = key
    }
    
}
