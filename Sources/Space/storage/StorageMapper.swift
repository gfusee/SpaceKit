public protocol StorageMapper {
    init(baseKey: Buffer)
    
    init(baseKey: Buffer, @StorageKeyBuilder _ otherKeys: () -> Buffer)
}

extension StorageMapper {
    // It would be fantastic to allow remove the baseKey arg and enforce using StaticString as the first block for StorageKeyBuilder,
    // but unfortunately, and only in result builder, Swift considers literal values as String.
    // TODO: open an issue on the Swift forum or repository
    public init(baseKey: Buffer, @StorageKeyBuilder _ otherKeys: () -> Buffer) {
        self.init(baseKey: baseKey + otherKeys())
    }
}
