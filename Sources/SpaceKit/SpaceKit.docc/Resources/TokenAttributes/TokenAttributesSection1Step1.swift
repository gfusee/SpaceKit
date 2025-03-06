import SpaceKit

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
