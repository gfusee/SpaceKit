@propertyWrapper public struct UserMapping {
    
    private let key: Buffer
    
    public var wrappedValue: UserMapper {
        get {
            return UserMapper(baseKey: key)
        }
    }
    
    public init(
        key: Buffer
    ) {
        self.key = key
    }
    
}
