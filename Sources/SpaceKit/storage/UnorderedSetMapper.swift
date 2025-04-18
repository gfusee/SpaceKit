// TODO: add tests

fileprivate let NULL_ENTRY: UInt32 = 0
fileprivate let ITEM_INDEX: StaticString = ".index"

public struct UnorderedSetMapper<V: TopEncode & NestedEncode & TopDecode>: StorageMapper {
    private let baseKey: Buffer
    private let vecMapper: VecMapper<V>
    
    public var count: UInt32 {
        self.vecMapper.count
    }
    
    public var isEmpty: Bool {
        self.vecMapper.isEmpty
    }
    
    public init(baseKey: Buffer) {
        self.baseKey = baseKey
        self.vecMapper = VecMapper(baseKey: baseKey)
    }
    
    private func getItemIndexMapper(value: V) -> SingleValueMapper<UInt32> {
        var valueEncoded = Buffer()
        value.depEncode(dest: &valueEncoded)
        
        return SingleValueMapper(baseKey: self.baseKey + Buffer(stringLiteral: ITEM_INDEX) + valueEncoded)
    }
    
    private func getIndex(value: V) -> UInt32 {
        return self.getItemIndexMapper(value: value).get()
    }
    
    private func getByIndex(index: UInt32) -> V {
        return self.vecMapper.get(index: index)
    }
    
    public func contains(value: V) -> Bool {
        return self.getIndex(value: value) != NULL_ENTRY
    }
    
    public func insert(value: V) -> Bool {
        guard !self.contains(value: value) else {
            return false
        }
        
        let _ = self.vecMapper.append(item: value)
        self.getItemIndexMapper(value: value).set(self.count)
        
        return true
    }
    
    public func swapRemove(value: V) -> Bool {
        let valueItemIndexMapper = self.getItemIndexMapper(value: value)
        let index = valueItemIndexMapper.get()
        
        guard index != NULL_ENTRY else {
            return false
        }
        
        if let lastItem = self.vecMapper.swapRemoveAndGetOldLast(index: index) {
            self.getItemIndexMapper(value: lastItem).set(index)
        }
        
        valueItemIndexMapper.clear()
        
        return true
    }
    
    public func swapIndexes(index1: UInt32, index2: UInt32) -> Bool {
        guard index1 != NULL_ENTRY && index2 != NULL_ENTRY else {
            return false
        }
        
        let value1 = self.getByIndex(index: index1)
        let value2 = self.getByIndex(index: index2)
        self.vecMapper.set(index: index2, item: value1)
        self.vecMapper.set(index: index1, item: value2)
        self.getItemIndexMapper(value: value1).set(index2)
        self.getItemIndexMapper(value: value2).set(index1)
        
        return true
    }
    
    public func clear() {
        self.vecMapper.forEach { value in
            self.getItemIndexMapper(value: value).clear()
        }
        
        self.vecMapper.clear()
    }
}

extension UnorderedSetMapper: Sequence {
    public func makeIterator() -> VecMapper<V>.Iterator {
        Iterator(mapper: self.vecMapper)
    }
}

extension UnorderedSetMapper: SpaceSequence {
    public func forEach(_ operations: (V) throws -> Void) rethrows {
        for element in self {
            try operations(element)
        }
    }
}
