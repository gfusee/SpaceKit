import SpaceKit

@Init func initialize(
    pingAmount: BigUint,
    durationInSeconds: UInt64,
    optActivationTimestamp: UInt64?,
    maxFunds: OptionalArgument<BigUint>
) {
    var controller = PingPongController()
    
    controller.pingAmount = pingAmount
    let activationTimestamp = if let activationTimestamp = optActivationTimestamp {
        activationTimestamp
    } else {
        Blockchain.getBlockTimestamp()
    }
    
    let deadline = activationTimestamp + durationInSeconds
    controller.deadline = deadline
    controller.activationTimestamp = activationTimestamp
    controller.maxFunds = maxFunds.intoOptional()
}
