// TODO: add tests

fileprivate let NULL_ENTRY: UInt32 = 0
fileprivate let INFO_IDENTIFIER: StaticString = ".info"
fileprivate let NODE_IDENTIFIER: StaticString = ".node_links"
fileprivate let VALUE_IDENTIFIER: StaticString = ".value"

@Codable package struct Node {
    var previous: UInt32
    var next: UInt32
}

@Codable package struct QueueMapperInfo {
    var len: UInt32
    var front: UInt32
    var back: UInt32
    var new: UInt32
}

fileprivate extension QueueMapperInfo {
    mutating func generateNewNodeId() -> UInt32 {
        self.new += 1
        return self.new
    }
}

fileprivate func  getDefaultInfo() -> QueueMapperInfo {
    return QueueMapperInfo(len: 0, front: 0, back: 0, new: 0)
}

public struct QueueMapper<V: TopEncode & TopDecode> {
    private let baseKey: Buffer
    
    public init(baseKey: Buffer) {
        self.baseKey = baseKey
    }
    
    private func buildNameKey(name: Buffer) -> Buffer {
        return self.baseKey + name
    }
    
    private func buildNodeIdNamedKey(name: Buffer, nodeId: UInt32) -> Buffer {
        var nodeIdNestedEncoded = Buffer()
        nodeId.depEncode(dest: &nodeIdNestedEncoded)
        
        return self.baseKey + name + nodeIdNestedEncoded
    }
    
    package func getInfoMapper() -> SingleValueMapper<QueueMapperInfo> {
        return SingleValueMapper(key: self.buildNameKey(name: Buffer(stringLiteral: INFO_IDENTIFIER)))
    }
    
    package func getNodeMapper(nodeId: UInt32) -> SingleValueMapper<Node> {
        return SingleValueMapper(key: self.buildNodeIdNamedKey(name: Buffer(stringLiteral: NODE_IDENTIFIER), nodeId: nodeId))
    }
    
    package func getValueMapper(nodeId: UInt32) -> SingleValueMapper<V> {
        return SingleValueMapper(key: self.buildNodeIdNamedKey(name: Buffer(stringLiteral: VALUE_IDENTIFIER), nodeId: nodeId))
    }
    
    package func getValue(nodeId: UInt32) -> V {
        return self.getValueMapper(nodeId: nodeId).get()
    }
    
    package func getValueOption(nodeId: UInt32) -> V? {
        if nodeId == NULL_ENTRY {
            return nil
        }
        
        return self.getValue(nodeId: nodeId)
    }
    
    package func pushBackNodeId(value: V) -> UInt32 {
        var infoMapper = self.getInfoMapper()
        
        var info = infoMapper.isEmpty() ? getDefaultInfo() : infoMapper.get()
        let newNodeId = info.generateNewNodeId()
        
        var previous = NULL_ENTRY
        
        if info.len == 0 {
            info.front = newNodeId
        } else {
            let back = info.back
            let backNodeMapper = self.getNodeMapper(nodeId: back)
            var backNode = backNodeMapper.get()
            backNode.next = newNodeId
            previous = back
            backNodeMapper.set(backNode)
        }
        
        let newNodeMapper = self.getNodeMapper(nodeId: newNodeId)
        newNodeMapper.set(Node(previous: previous, next: NULL_ENTRY))
        info.back = newNodeId
        let valueMapper = self.getValueMapper(nodeId: newNodeId)
        valueMapper.set(value)
        info.len += 1
        infoMapper.set(info)
        
        return newNodeId
    }
    
    public func isEmpty() -> Bool {
        let infoMapper = self.getInfoMapper()
        var info = infoMapper.isEmpty() ? getDefaultInfo() : infoMapper.get()
        
        return info.len == 0
    }
    
    public func pushFront(value: V) {
        let infoMapper = self.getInfoMapper()
        var info = infoMapper.isEmpty() ? getDefaultInfo() : infoMapper.get()
        
        let newNodeId = info.generateNewNodeId()
        var next = NULL_ENTRY
        if info.len == 0 {
            info.back = newNodeId
        } else {
            let front = info.front
            let frontNodeMapper = self.getNodeMapper(nodeId: front)
            var frontNode = frontNodeMapper.get()
            frontNode.previous = newNodeId
            next = front
            frontNodeMapper.set(frontNode)
        }
        let newNodeMapper = self.getNodeMapper(nodeId: newNodeId)
        newNodeMapper.set(
            Node(previous: NULL_ENTRY, next: next)
        )
        
        info.front = newNodeId
        let valueMapper = self.getValueMapper(nodeId: newNodeId)
        valueMapper.set(value)
        info.len += 1
        infoMapper.set(info)
    }
    
    public func pushBack(value: V) {
        let _ = self.pushBackNodeId(value: value)
    }
    
    
    package func removeByNodeId(nodeId: UInt32) -> V? {
        if nodeId == NULL_ENTRY {
            return nil
        }
        
        let nodeMapper = self.getNodeMapper(nodeId: nodeId)
        let node = nodeMapper.get()
        
        let infoMapper = self.getInfoMapper()
        var info = infoMapper.isEmpty() ? getDefaultInfo() : infoMapper.get()
        
        if node.previous == NULL_ENTRY {
            info.front = node.next
        } else {
            let previousNodeMapper = self.getNodeMapper(nodeId: node.previous)
            var previousNode = previousNodeMapper.get()
            
            previousNode.next = node.next
            
            previousNodeMapper.set(previousNode)
        }
        
        if node.next == NULL_ENTRY {
            info.back = node.previous
        } else {
            let nextNodeMapper = self.getNodeMapper(nodeId: node.next)
            var nextNode = nextNodeMapper.get()
            
            nextNode.previous = node.previous
            nextNodeMapper.set(nextNode)
        }
        
        
        nodeMapper.clear()
        
        let valueMapper = self.getValueMapper(nodeId: nodeId)
        let removedValue = valueMapper.get()
        valueMapper.clear()
        info.len -= 1
        infoMapper.set(info)
        
        return removedValue
    }
    
    public func clear() {
        let infoMapper = self.getInfoMapper()
        let info = infoMapper.isEmpty() ? getDefaultInfo() : infoMapper.get()
        
        var nodeId = info.front
        
        while nodeId != NULL_ENTRY {
            let nodeMapper = self.getNodeMapper(nodeId: nodeId)
            let node = nodeMapper.get()
            nodeMapper.clear()
            self.getValueMapper(nodeId: nodeId).clear()
            nodeId = node.next
        }
        
        infoMapper.clear()
    }
}

extension QueueMapper: MXSequence {
    public func forEach(_ operations: (V) throws -> Void) rethrows {
        let infoMapper = self.getInfoMapper()
        let info = infoMapper.isEmpty() ? getDefaultInfo() : infoMapper.get()
        
        var currentNodeId = info.front
        
        while currentNodeId != NULL_ENTRY {
            try operations(self.getValueMapper(nodeId: currentNodeId).get())
            currentNodeId = self.getNodeMapper(nodeId: currentNodeId).get().next
        }
    }
}
