// TODO: add tests

fileprivate let NULL_ENTRY: UInt32 = 0
fileprivate let NODE_ID_IDENTIFIER: StaticString = ".node_id"

public struct SetMap<V: TopEncode & NestedEncode & TopDecode> {
    // TODO: add tests
    private let baseKey: MXBuffer
    private let queueMapper: QueueMap<V>
    
    public init(baseKey: MXBuffer) {
        self.baseKey = baseKey
        self.queueMapper = QueueMap(baseKey: baseKey)
    }
    
    private func buildNamedValueKey(name: MXBuffer, value: V) -> MXBuffer {
        var valueNestedEncoded = MXBuffer()
        value.depEncode(dest: &valueNestedEncoded)
        
        return self.baseKey + name + valueNestedEncoded
    }
    
    private func getNodeIdMapper(value: V) -> SingleValueMapper<UInt32> {
        return SingleValueMapper(key: self.buildNamedValueKey(name: MXBuffer(stringLiteral: NODE_ID_IDENTIFIER), value: value))
    }
    
    private func contains(value: V) -> Bool {
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
    
    public func extend<I: Sequence<V>>(iterable: I) {
        for element in iterable {
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
    
    public func removeAll<I: Sequence<V>>(iterable: I) {
        for element in iterable {
            let _ = self.remove(value: element)
        }
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

extension SetMap: Sequence {
    public func makeIterator() -> QueueMapIterator<V> {
        QueueMapIterator(queueMap: self.queueMapper)
    }
}

extension SetMap: TopEncodeMulti {
    public func multiEncode<O>(output: inout O) where O : TopEncodeMultiOutput {
        for element in self {
            output.pushSingleValue(arg: element)
        }
    }
}
