public struct SingleValueMapper<V: TopEncode & TopDecode>: StorageMapper {
    private let key: Buffer
    
    public init(baseKey: Buffer) {
        self.key = baseKey
    }

    public func clear() {
        // TODO: add tests
        clearStorage(key: self.key)
    }

    public func isEmpty() -> Bool {
        // TODO: add tests
        return self.getRawBuffer().count == 0
    }
    
    public func take() -> V {
        let value = self.get()
        self.clear()
        
        return value
    }
    
    private func getRawBuffer() -> Buffer {
        let storedValueBufferHandle = API.getNextHandle()
        let _ = API.bufferStorageLoad(keyHandle: self.key.handle, bufferHandle: storedValueBufferHandle)
        
        return Buffer(handle: storedValueBufferHandle)
    }
    
    public func get() -> V {
        return V(topDecode: self.getRawBuffer())
    }
    
    public func set(_ newValue: V) {
        var output = Buffer()
        newValue.topEncode(output: &output)
        
        let _ = API.bufferStorageStore(keyHandle: self.key.handle, bufferHandle: output.handle)
    }
    
    public func update<R>(_ operations: (inout V) -> R) -> R {
        // TODO: add tests, especially on the inout part
        var value = self.get()
        let result = operations(&value)
        self.set(value)
        
        return result
    }
}

extension SingleValueMapper: TopEncodeMulti where V: TopEncodeMulti {
    public func multiEncode<O>(output: inout O) where O : TopEncodeMultiOutput {
        self.get().multiEncode(output: &output)
    }
}

#if !WASM
extension SingleValueMapper: ABITypeExtractor where V: ABITypeExtractor {
    public static var _abiTypeName: String {
        V._abiTypeName
    }
}
#endif

#if !WASM
extension SingleValueMapper: TopDecodeMulti where V: TopDecodeMulti {
    public typealias SwiftVMDecoded = V.SwiftVMDecoded
    
    static public func fromTopDecodeMultiInput(_ input: inout some TopDecodeMultiInput) -> V.SwiftVMDecoded {
        V.fromTopDecodeMultiInput(&input)
    }
    
    public init(topDecodeMulti input: inout some TopDecodeMultiInput) {
        smartContractError(message: "SingleValueMapper should not be decoded using TopDecodeMulti in the SwiftVM. If you encounter this error please open an issue on GitHub.")
    }
}
#endif
