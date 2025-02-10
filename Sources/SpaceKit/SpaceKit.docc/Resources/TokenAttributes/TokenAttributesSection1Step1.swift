import SpaceKit

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
