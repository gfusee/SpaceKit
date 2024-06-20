public struct MXArray<T: TopDecode & TopEncode & NestedDecode & NestedEncode & ArrayItem> {
    let buffer: MXBuffer
    
    public init() {
        self.buffer = MXBuffer()
    }
    
    init(handle: Int32) {
        self.buffer = MXBuffer(handle: handle)
    }
    
    public init(buffer: MXBuffer) {
        self.buffer = buffer.clone()
    }
    
    public var count: Int {
        return self.buffer.count / Int(T.payloadSize) // TODO: could this Int casting overflow?
    }
    
    public func appended(_ item: T) -> MXArray {
        let payload = item.intoArrayPayload()
        let newBuffer = self.buffer + payload
        
        return MXArray(buffer: newBuffer)
    }
    
    public func get(_ index: Int) -> T {
        guard index < self.count else {
            smartContractError(message: "Index out of range.") // TODO: use the same message than the Rust SDK
        }
        
        let payloadSize = Int(T.payloadSize) // TODO: could this Int casting overflow?
        
        let startIndex = index * payloadSize
        
        let data = self.buffer.getSubBuffer(startIndex: startIndex, length: payloadSize)
        
        return T.decodeArrayPayload(payload: data)
    }
    
    public subscript(_ index: Int) -> T {
        get {
            self.get(index)
        } set {
            fatalError() // TODO
        }
    }
}
