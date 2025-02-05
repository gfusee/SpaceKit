import SpaceKit

@Controller public struct BlockInfoController {
    public func getCurrentBlockNonce() -> UInt64 {
        Blockchain.getBlockNonce()
    }
    
    public func getCurrentBlockTimestamp() -> UInt64 {
        Blockchain.getBlockTimestamp()
    }
    
    public func getCurrentBlockRound() -> UInt64 {
        Blockchain.getBlockRound()
    }
    
    public func getCurrentBlockEpoch() -> UInt64 {
        Blockchain.getBlockEpoch()
    }
}
