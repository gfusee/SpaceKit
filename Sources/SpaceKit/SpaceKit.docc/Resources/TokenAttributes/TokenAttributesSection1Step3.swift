import SpaceKit

@Codable public struct LockedTokenAttributes {
    let creationTimestamp: UInt64
    let lockDuration: UInt64
    let lockedEgldAmount: BigUint
}

@Init public func initialize(
    tokenIdentifier: TokenIdentifier,
    lockDuration: UInt64
) {
    var controller = MyContract()
    
    controller.tokenIdentifier = tokenIdentifier
    controller.lockDuration = lockDuration
}

@Controller struct LockController {
    TokenIdentifier:@Storage(key: "tokenIdentifier") var tokenIdentifier: TokenIdentifier
    @Storage(key: "lockDuration") var lockDuration: UInt64
    
    public func lockFunds() -> UInt64 {
        
    }
}

