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
        
        for item in self {
            result = result.appended(item)
        }
        
        return result
    }
}

public struct MultiValueEncodedIterator<Item: MXCodable>: IteratorProtocol {
    // TODO: add tests
    let multiValueEncoded: MultiValueEncoded<Item>
    let count: Int32
    
    var index: Int32 = 0
    
    init(multiValueEncoded: MultiValueEncoded<Item>) {
        self.count = multiValueEncoded.count
        self.multiValueEncoded = multiValueEncoded
    }
    
    public mutating func next() -> Item? {
        guard self.index < self.count else {
            return nil
        }
        
        let result = self.multiValueEncoded.get(self.index)
        
        self.index += 1
        
        return result
    }
}

extension MultiValueEncoded: Sequence {
    public func makeIterator() -> MultiValueEncodedIterator<Item> {
        MultiValueEncodedIterator(multiValueEncoded: self)
    }
}

extension MultiValueEncoded: TopEncodeMulti {
    public func multiEncode<O>(output: inout O) where O : TopEncodeMultiOutput {
        for buffer in self.rawBuffers {
            buffer.multiEncode(output: &output)
        }
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
