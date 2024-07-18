@propertyWrapper public struct UserMapping {
    
    private let key: MXBuffer
    
    public var wrappedValue: UserMap {
        get {
            return UserMap(baseKey: key)
        }
    }
    
    public init(
        key: MXBuffer
    ) {
        self.key = key
    }
    
}
