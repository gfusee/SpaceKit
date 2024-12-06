import SpaceKit

@Init func initialize(
    target: BigUint,
    deadline: UInt64,
    tokenIdentifier: Buffer
) {
    var controller = CrowdfundingEsdtController()
    
    require(target > 0, "Target must be more than 0")
    controller.target = target

    require(
        deadline > Blockchain.getBlockTimestamp(),
        "Deadline can't be in the past"
    )
    controller.deadline = deadline

    // TODO: once the TokenIdentifier type is implemented, add a require to check if it is valid
    controller.tokenIdentifier = tokenIdentifier
}
