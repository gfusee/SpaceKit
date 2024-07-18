@propertyWrapper public struct Mapping<T: TopEncode & TopDecode, K: NestedEncode> {
    
    private let key: MXBuffer
    
    public var wrappedValue: StorageMap<K, T> {
        get {
            StorageMap(baseKey: self.key)
        } set {
            
        }
    }
    
    public init(
        key: MXBuffer
    ) {
        self.key = key
    }
    
}
