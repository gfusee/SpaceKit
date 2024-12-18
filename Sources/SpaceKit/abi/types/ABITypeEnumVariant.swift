#if !WASM
public struct ABITypeEnumVariant: Encodable {
    let name: String
    let discriminant: UInt8
    let fields: [ABITypeStructField]?
    
    public init(
        name: String,
        discriminant: UInt8,
        fields: [ABITypeStructField]? = nil
    ) {
        self.name = name
        self.discriminant = discriminant
        self.fields = fields
    }
}
#endif
