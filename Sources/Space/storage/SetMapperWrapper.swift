@propertyWrapper public struct SetMapping<V: TopEncode & NestedEncode & TopDecode> {
    
    private let key: Buffer
    
    public var wrappedValue: SetMapper<V> {
        get {
            return SetMapper(baseKey: key)
        }
    }
    
    public init(
        key: Buffer
    ) {
        self.key = key
    }
    
}
