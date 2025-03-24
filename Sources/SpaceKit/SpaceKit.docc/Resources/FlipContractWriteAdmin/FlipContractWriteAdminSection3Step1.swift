import SpaceKit

@Controller public struct AdminController {
    public func setMinimumBlockBounty(
        value: UInt64
    ) {
        assertOwner()
        
        require(
            value > 0,
            "Minimum block bounty should be greater than zero."
        )
        
        var storageController = StorageController()
        storageController.minimumBlockBounty = value
    }
    
    public func setMaximumBet(
        tokenIdentifier: TokenIdentifier,
        nonce: UInt64,
        amount: BigUint
    ) {
        assertOwner()
        
        require(
            amount > 0,
            "Amount should be greater than zero."
        )
        
        StorageController()
            .getMaximumBet(
                tokenIdentifier: tokenIdentifier,
                tokenNonce: nonce
            )
            .set(amount)
    }
    
    public func setMaximumBetPercent(
        tokenIdentifier: TokenIdentifier,
        nonce: UInt64,
        percent: UInt64
    ) {
        assertOwner()
        
        require(
            percent > 0,
            "Percent should be greater than zero."
        )
        
        StorageController()
            .getMaximumBetPercent(
                tokenIdentifier: tokenIdentifier,
                tokenNonce: nonce
            )
            .set(percent)
    }
}
