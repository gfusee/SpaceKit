@propertyWrapper public struct UserMapping {
    
    private let key: MXBuffer
    
    public var wrappedValue: UserMapper {
        get {
            return UserMapper(baseKey: key)
        }
    }
    
    public init(
        key: MXBuffer
    ) {
        self.key = key
    }
    
}
