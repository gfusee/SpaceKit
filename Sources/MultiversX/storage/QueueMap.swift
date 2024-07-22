fileprivate let NULL_ENTRY: UInt32 = 0
fileprivate let INFO_IDENTIFIER: StaticString = ".info"
fileprivate let NODE_IDENTIFIER: StaticString = ".node_links"
fileprivate let VALUE_IDENTIFIER: StaticString = ".value"

@Codable struct Node {
    var previous: UInt32
    var next: UInt32
}

@Codable struct QueueMapperInfo {
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

public struct QueueMap<V: TopEncode & TopDecode> {
    private let baseKey: MXBuffer
    
    public init(baseKey: MXBuffer) {
        self.baseKey = baseKey
    }
    
    private func buildNameKey(name: MXBuffer) -> MXBuffer {
        return self.baseKey + name
    }
    
    private func buildNodeIdNamedKey(name: MXBuffer, nodeId: UInt32) -> MXBuffer {
        var nodeIdNestedEncoded = MXBuffer()
        nodeId.depEncode(dest: &nodeIdNestedEncoded)
        
        return self.baseKey + name + nodeIdNestedEncoded
    }
    
    private func getInfoMapper() -> SingleValueMapper<QueueMapperInfo> {
        return SingleValueMapper(key: self.buildNameKey(name: MXBuffer(stringLiteral: INFO_IDENTIFIER)))
    }
    
    private func getNodeMapper(nodeId: UInt32) -> SingleValueMapper<Node> {
        return SingleValueMapper(key: self.buildNodeIdNamedKey(name: MXBuffer(stringLiteral: NODE_IDENTIFIER), nodeId: nodeId))
    }
    
    private func getValueMapper(nodeId: UInt32) -> SingleValueMapper<V> {
        return SingleValueMapper(key: self.buildNodeIdNamedKey(name: MXBuffer(stringLiteral: VALUE_IDENTIFIER), nodeId: nodeId))
    }
    
    private func getValue(nodeId: UInt32) -> V {
        return self.getValueMapper(nodeId: nodeId).get()
    }
    
    private func getValueOption(nodeId: UInt32) -> V? {
        if nodeId == NULL_ENTRY {
            return nil
        }
        
        return self.getValue(nodeId: nodeId)
    }
    
    private func pushBackNodeId(value: V) -> UInt32 {
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
}