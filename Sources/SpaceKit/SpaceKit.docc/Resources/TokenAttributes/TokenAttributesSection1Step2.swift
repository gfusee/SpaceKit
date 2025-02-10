import SpaceKit

@Codable public struct LockedTokenAttributes {
    let creationTimestamp: UInt64
    let lockDuration: UInt64
    let lockedEgldAmount: BigUint
}

@Init public func initialize(
    tokenIdentifier: Buffer,
    lockDuration: UInt64
) {
    var controller = MyContract()
    
    controller.tokenIdentifier = tokenIdentifier
    controller.lockDuration = lockDuration
}

@Controller struct LockController {
    @Storage(key: "tokenIdentifier") var tokenIdentifier: Buffer
    @Storage(key: "lockDuration") var lockDuration: UInt64
}

