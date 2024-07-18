@propertyWrapper public struct Storage<T: TopEncode & TopDecode> {
    
    private let key: MXBuffer
    
    public var wrappedValue: T {
        get {
            return SingleValueMapper(key: key).get()
        }
        set {
            SingleValueMapper(key: key).set(newValue)
        }
    }
    
    public var projectedValue: SingleValueMapper<T> {
        SingleValueMapper(key: self.key)
    }
    
    public init(
        key: MXBuffer
    ) {
        self.key = key
    }
    
}
