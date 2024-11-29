@resultBuilder public struct StorageKeyBuilder {
    public static func buildPartialBlock(first: some NestedEncode) -> Buffer {
        var result = Buffer()
        first.depEncode(dest: &result)
        
        return result
    }
    
    public static func buildPartialBlock(accumulated: Buffer, next: some NestedEncode) -> Buffer {
        var result = accumulated
        next.depEncode(dest: &result)
        
        return result
    }
}
