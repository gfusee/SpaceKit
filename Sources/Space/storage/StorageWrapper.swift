@propertyWrapper public struct Storage<T: TopEncode & TopDecode> {
    
    private let key: Buffer
    
    public var wrappedValue: T {
        get {
            return SingleValueMapper(baseKey: key).get()
        }
        set {
            SingleValueMapper(baseKey: key).set(newValue)
        }
    }
    
    public var projectedValue: SingleValueMapper<T> {
        SingleValueMapper(baseKey: self.key)
    }
    
    public init(
        key: Buffer
    ) {
        self.key = key
    }
    
}
