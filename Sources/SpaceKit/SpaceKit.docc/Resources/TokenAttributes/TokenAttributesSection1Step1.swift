import SpaceKit

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
}
