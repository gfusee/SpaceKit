import SpaceKit

@Init func initialize(
    target: BigUint,
    deadline: UInt64,
    tokenIdentifier: TokenIdentifier
) {
    var controller = CrowdfundingEsdtController()
    
    require(target > 0, "Target must be more than 0")
    controller.target = target

    require(
        deadline > Blockchain.getBlockTimestamp(),
        "Deadline can't be in the past"
    )
    controller.deadline = deadline

    require(
        tokenIdentifier.isValidESDT || tokenIdentifier.isEGLD,
        "invalid token identifier"
    )
    controller.tokenIdentifier = tokenIdentifier
}
