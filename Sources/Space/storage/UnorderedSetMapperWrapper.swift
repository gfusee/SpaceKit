@propertyWrapper public struct UnorderedSetMapping<V: TopEncode & NestedEncode & TopDecode> {
    
    private let key: MXBuffer
    
    public var wrappedValue: UnorderedSetMapper<V> {
        get {
            return UnorderedSetMapper(baseKey: key)
        }
    }
    
    public init(
        key: MXBuffer
    ) {
        self.key = key
    }
    
}
