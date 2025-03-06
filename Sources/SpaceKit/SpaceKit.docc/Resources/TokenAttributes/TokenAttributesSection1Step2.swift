import SpaceKit

@Codable public struct LockedTokenAttributes {
    let creationTimestamp: UInt64
    var lockDuration: UInt64
    let lockedEgldAmount: BigUint
}

@Init public func initialize(
    tokenIdentifier: TokenIdentifier,
    lockDuration: UInt64
) {
    var controller = LockController()
    
    controller.tokenIdentifier = tokenIdentifier
    controller.lockDuration = lockDuration
}

@Controller public struct LockController {
    @Storage(key: "tokenIdentifier") var tokenIdentifier: TokenIdentifier
    @Storage(key: "lockDuration") var lockDuration: UInt64
}

