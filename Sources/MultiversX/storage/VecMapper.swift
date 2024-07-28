// TODO: add tests

fileprivate let INDEX_OUT_OF_RANGE_ERROR: StaticString = "index out of range"
fileprivate let ITEM_SUFFIX: StaticString = ".item"
fileprivate let LEN_SUFFIX: StaticString = ".len"

public struct VecMapper<V: TopEncode & NestedEncode & TopDecode> {
    // TODO: add tests
    private let baseKey: MXBuffer
    private let lenKey: MXBuffer
    
    public init(baseKey: MXBuffer) {
        self.baseKey = baseKey
        self.lenKey = baseKey + MXBuffer(stringLiteral: LEN_SUFFIX)
    }
    
    public var count: UInt32 {
        self.getLenMapper().get()
    }
    
    private func getItemMapper(index: UInt32) -> SingleValueMapper<V> {
        var itemEncoded = MXBuffer()
        index.depEncode(dest: &itemEncoded)
        
        return SingleValueMapper(key: self.baseKey + MXBuffer(stringLiteral: ITEM_SUFFIX) + itemEncoded)
    }
    
    private func getLenMapper() -> SingleValueMapper<UInt32> {
        return SingleValueMapper(key: self.lenKey)
    }
    
    public func isEmpty() -> Bool {
        return self.count == 0
    }
    
    public func get(index: UInt32) -> V {
        guard index != 0 && index < self.count else {
            smartContractError(message: MXBuffer(stringLiteral: INDEX_OUT_OF_RANGE_ERROR))
        }
        
        return self.getUnchecked(index: index)
    }
    
    public func getUnchecked(index: UInt32) -> V {
        return self.getItemMapper(index: index).get()
    }
    
    public func append(item: V) -> UInt32 {
        let newCount = self.count + 1
        self.getItemMapper(index: newCount).set(item)
        self.getLenMapper().set(newCount)
        
        return newCount
    }
    
    public func set(index: UInt32, item: V) {
        guard index != 0 && index < self.count else {
            smartContractError(message: MXBuffer(stringLiteral: INDEX_OUT_OF_RANGE_ERROR))
        }
        
        self.setUnchecked(index: index, item: item)
    }
    
    public func setUnchecked(index: UInt32, item: V) {
        self.getItemMapper(index: index).set(item)
    }
    
    public func clear() {
        let count = self.count
        
        for index in 1...count {
            self.getItemMapper(index: index).clear()
        }
        
        self.getLenMapper().set(0)
    }
    
    public func clearEntry(index: UInt32) {
        guard index != 0 && index < self.count else {
            smartContractError(message: MXBuffer(stringLiteral: INDEX_OUT_OF_RANGE_ERROR))
        }
        
        let _ = self.clearEntryUnchecked(index: index)
    }
    
    public func clearEntryUnchecked(index: UInt32) {
        self.getItemMapper(index: index).clear()
    }
    
    public func swapRemove(index: UInt32) {
        let _ = self.swapRemoveAndGetOldLast(index: index)
    }
    
    package func swapRemoveAndGetOldLast(index: UInt32) -> V? {
        let lastItemIndex = self.count
        
        guard index != 0 && index < self.count else {
            smartContractError(message: MXBuffer(stringLiteral: INDEX_OUT_OF_RANGE_ERROR))
        }
        
        var lastItemOptional: V? = nil
        
        if index != lastItemIndex {
            let lastItem = self.get(index: lastItemIndex)
            self.set(index: index, item: lastItem)
            lastItemOptional = lastItem
        }
        
        self.clearEntry(index: lastItemIndex)
        self.getLenMapper().set(lastItemIndex - 1)
        return lastItemOptional
    }
}


extension VecMapper: MXSequence {
    public func forEach(_ operations: (V) throws -> Void) rethrows {
        let count = self.count
        var index: UInt32 = 1
        
        while index <= count {
            let element = self.getUnchecked(index: index)
            try operations(element)
            
            index += 1
        }
    }
}
