@propertyWrapper public struct UnorderedSetMapping<V: TopEncode & NestedEncode & TopDecode> {
    
    private let key: Buffer
    
    public var wrappedValue: UnorderedSetMapper<V> {
        get {
            return UnorderedSetMapper(baseKey: key)
        }
    }
    
    public init(
        key: Buffer
    ) {
        self.key = key
    }
    
}
