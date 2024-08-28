@propertyWrapper public struct SetMapping<V: TopEncode & NestedEncode & TopDecode> {
    
    private let key: MXBuffer
    
    public var wrappedValue: SetMapper<V> {
        get {
            return SetMapper(baseKey: key)
        }
    }
    
    public init(
        key: MXBuffer
    ) {
        self.key = key
    }
    
}
