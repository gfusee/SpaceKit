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
            "Amount should be greater than zero."
        )
        
        StorageController()
            .getMaximumBetPercent(
                tokenIdentifier: tokenIdentifier,
                tokenNonce: nonce
            )
            .set(percent)
    }
    
    public func increaseReserve() {
        assertOwner()
        
        let payment = Message.egldOrSingleEsdtTransfer
        
        require(
            payment.amount > 0,
            "No payment received."
        )
        
        _ = StorageController()
            .getTokenReserve(
                tokenIdentifier: payment.tokenIdentifier,
                tokenNonce: payment.nonce
            )
            .update { $0 + payment.amount }
    }
    
    public func withdrawReserve(
        tokenIdentifier: TokenIdentifier,
        nonce: UInt64,
        amount: BigUint
    ) {
        assertOwner()
        
        _ = StorageController()
            .getTokenReserve(
                tokenIdentifier: tokenIdentifier,
                tokenNonce: nonce
            )
            .update { tokenReserve in
                require(
                    tokenReserve <= amount,
                    "Amount too high"
                )
                
                return tokenReserve - amount
            }
        
        Blockchain
            .getOwner()
            .send(
                tokenIdentifier: tokenIdentifier,
                nonce: nonce,
                amount: amount
            )
    }
}
