@propertyWrapper public struct SetMapping<V: TopEncode & NestedEncode & TopDecode> {
    
    private let key: MXBuffer
    
    public var wrappedValue: SetMap<V> {
        get {
            return SetMap(baseKey: key)
        }
    }
    
    public init(
        key: MXBuffer
    ) {
        self.key = key
    }
    
}
