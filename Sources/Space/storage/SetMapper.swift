// TODO: add tests

fileprivate let NULL_ENTRY: UInt32 = 0
fileprivate let NODE_ID_IDENTIFIER: StaticString = ".node_id"

public struct SetMapper<V: TopEncode & NestedEncode & TopDecode>: StorageMapper {
    // TODO: add tests
    private let baseKey: Buffer
    private let queueMapper: QueueMapper<V>
    
    public init(baseKey: Buffer) {
        self.baseKey = baseKey
        self.queueMapper = QueueMapper(baseKey: baseKey)
    }
    
    private func buildNamedValueKey(name: Buffer, value: V) -> Buffer {
        var valueNestedEncoded = Buffer()
        value.depEncode(dest: &valueNestedEncoded)
        
        return self.baseKey + name + valueNestedEncoded
    }
    
    private func getNodeIdMapper(value: V) -> SingleValueMapper<UInt32> {
        return SingleValueMapper(baseKey: self.buildNamedValueKey(name: Buffer(stringLiteral: NODE_ID_IDENTIFIER), value: value))
    }
    
    public func isEmpty() -> Bool {
        return self.queueMapper.isEmpty()
    }
    
    public func contains(value: V) -> Bool {
        return self.getNodeIdMapper(value: value).get() != NULL_ENTRY
    }
    
    public func insert(value: V) -> Bool {
        guard !self.contains(value: value) else {
            return false
        }
        
        let newNodeId = self.queueMapper.pushBackNodeId(value: value)
        self.getNodeIdMapper(value: value).set(newNodeId)
        
        return true
    }
    
    public func extend<I: SpaceSequence>(iterable: I) where I.V == V {
        iterable.forEach { element in
            let _ = self.insert(value: element)
        }
    }
    
    public func remove(value: V) -> Bool {
        let nodeIdMapper = self.getNodeIdMapper(value: value)
        let nodeId = nodeIdMapper.get()
        
        if nodeId == NULL_ENTRY {
            return false
        }
        
        let _ = self.queueMapper.removeByNodeId(nodeId: nodeId)
        nodeIdMapper.clear()
        
        return true
    }
    
    public func removeAll<I: SpaceSequence>(iterable: I) where I.V == V {
        iterable.forEach { element in
            let _ = self.remove(value: element)
        }
    }
    
    public func clear() {
        self.queueMapper.forEach { value in
            self.getNodeIdMapper(value: value).clear()
        }
        
        self.queueMapper.clear()
    }
    
    private func next(value: V) -> V? {
        let nodeIdMapper = self.getNodeIdMapper(value: value)
        let nodeId = nodeIdMapper.get()
        
        if nodeId == NULL_ENTRY {
            return nil
        }
        
        let nextNodeId = self.queueMapper.getNodeMapper(nodeId: nodeId).get().next
        
        return self.queueMapper.getValueOption(nodeId: nextNodeId)
    }
    
    private func previous(value: V) -> V? {
        let nodeIdMapper = self.getNodeIdMapper(value: value)
        let nodeId = nodeIdMapper.get()
        
        if nodeId == NULL_ENTRY {
            return nil
        }
        
        let previousNodeId = self.queueMapper.getNodeMapper(nodeId: nodeId).get().previous
        
        return self.queueMapper.getValueOption(nodeId: previousNodeId)
    }
}

extension SetMapper: SpaceSequence {
    public func forEach(_ operations: (V) throws -> Void) rethrows {
        try self.queueMapper.forEach(operations)
    }
}

extension SetMapper: TopEncodeMulti {
    public func multiEncode<O>(output: inout O) where O : TopEncodeMultiOutput {
        self.forEach { element in
            output.pushSingleValue(arg: element)
        }
    }
}
