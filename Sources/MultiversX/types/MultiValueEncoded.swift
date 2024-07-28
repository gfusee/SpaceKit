// TODO: add tests

public struct MultiValueEncoded<Item: MXCodable> {
    private var rawBuffers: MXArray<MXBuffer> = MXArray()
    
    public var count: Int32 {
        self.rawBuffers.count
    }
    
    package init(rawBuffers: MXArray<MXBuffer>) {
        self.rawBuffers = rawBuffers
    }
    
    public func appended(value: Item) -> MultiValueEncoded<Item> {
        var newRawBuffers = self.rawBuffers.clone()
        
        value.multiEncode(output: &newRawBuffers)
        
        return MultiValueEncoded(rawBuffers: rawBuffers)
    }
    
    public func get(_ index: Int32) -> Item {
        return Item(topDecode: self.rawBuffers.get(index))
    }
    
    public func toArray() -> MXArray<Item> {
        var result = MXArray<Item>()
        
        self.forEach { result = result.appended($0) }
        
        return result
    }
}

extension MultiValueEncoded: MXSequence {
    public func forEach(_ operations: (Item) throws -> Void) rethrows {
        let count = self.count
        var index: Int32 = 0
        
        while index < count {
            let element = self.get(index)
            try operations(element)
            
            index += 1
        }
    }
}

extension MultiValueEncoded: TopEncodeMulti {
    public func multiEncode<O>(output: inout O) where O : TopEncodeMultiOutput {
        self.rawBuffers.forEach { $0.multiEncode(output: &output) }
    }
}

extension MultiValueEncoded: TopDecodeMulti {
    public init(topDecodeMulti input: inout some TopDecodeMultiInput) {
        var rawBuffersField: MXArray<MXBuffer> = MXArray()
        
        while input.hasNext() {
            rawBuffersField = rawBuffersField.appended(input.nextValueInput())
        }
        
        self = MultiValueEncoded(rawBuffers: rawBuffersField)
    }
}
