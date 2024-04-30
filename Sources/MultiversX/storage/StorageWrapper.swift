@propertyWrapper public struct Storage<T: TopEncode & TopDecode> {
    
    private let key: MXBuffer
    
    public var wrappedValue: T {
        get {
            let storedValueBufferHandle = getNextHandle()
            let _ = API.bufferStorageLoad(keyHandle: self.key.handle, bufferHandle: storedValueBufferHandle)
            return T.topDecode(input: MXBuffer(handle: storedValueBufferHandle))
        }
        set {
            var output = MXBuffer()
            newValue.topEncode(output: &output)
            let _ = API.bufferStorageStore(keyHandle: self.key.handle, bufferHandle: output.handle)
        }
    }
    
    public init(
        key: MXBuffer
    ) {
        self.key = key
    }
    
}
