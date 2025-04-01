import SpaceKit

let HUNDRED_PERCENT: UInt64 = 10_000

@Controller public struct GameController {
    public func flip() {
        let payment = Message.egldOrSingleEsdtTransfer
        
        var storageController = StorageController()
        
        let tokenReserve = storageController
            .getTokenReserve(
                tokenIdentifier: payment.tokenIdentifier,
                tokenNonce: payment.nonce
            )
            .get()
        
        let maximumBet = storageController
            .getMaximumBet(
                tokenIdentifier: payment.tokenIdentifier,
                tokenNonce: payment.nonce
            )
            .get()
        
        let maximumBetPercent = storageController
            .getMaximumBetPercent(
                tokenIdentifier: payment.tokenIdentifier,
                tokenNonce: payment.nonce
            )
            .get()
        
        let hundred_percent = BigUint(value: HUNDRED_PERCENT)
        
        let maximumBetPercentComputed = tokenReserve * BigUint(value: maximumBetPercent) / hundred_percent
        let maximumAllowedBet = maximumBet.min(other: maximumBetPercentComputed)
        
        let ownerFees = payment.amount * BigUint(value: storageController.ownerPercentFees) / hundred_percent
        let bounty = payment.amount * BigUint(value: storageController.bountyPercentFees) / hundred_percent
        
        let amount = payment.amount - ownerFees - bounty
        
        require(
            amount <= maximumAllowedBet,
            "Bet is too high. Maximum allowed bet: \(maximumAllowedBet)"
        )
        
        let lastFlipId = storageController.lastFlipId
        let flipId = lastFlipId + 1
        
        let flip = Flip(
            id: flipId,
            playerAddress: Message.caller,
            tokenIdentifier: payment.tokenIdentifier,
            tokenNonce: payment.nonce,
            amount: amount,
            bounty: bounty,
            blockNonce: Blockchain.getBlockNonce(),
            minimumBlockBounty: storageController.minimumBlockBounty
        )
        
        storageController.getTokenReserve(
            tokenIdentifier: payment.tokenIdentifier,
            tokenNonce: payment.nonce
        )
        .set(tokenReserve - amount)
        
        if payment.tokenIdentifier.isEGLD {
            Blockchain.getOwner()
                .send(egldValue: ownerFees)
        } else {
            Blockchain.getOwner()
                .send(
                    tokenIdentifier: payment.tokenIdentifier,
                    nonce: payment.nonce,
                    amount: ownerFees
                )
        }
        
        storageController.flipForId[flipId] = flip
        storageController.lastFlipId = flipId
    }
    
    public func bounty() {
    }
    
    private func makeFlip(
        bountyAddress: Address,
        flip: Flip
    ) {
        let randomNumber = Randomness.nextUInt8InRange(min: 0, max: 2)
        let isWin = randomNumber == 1
        
        bountyAddress.send(
            tokenIdentifier: flip.tokenIdentifier,
            nonce: flip.tokenNonce,
            amount: flip.bounty
        )
        
        let profitIfWin = flip.amount * 2
        
        let storageController = StorageController()
        
        if isWin {
            if flip.tokenIdentifier.isEGLD {
                flip.playerAddress
                    .send(egldValue: profitIfWin)
            } else {
                flip.playerAddress
                    .send(
                        tokenIdentifier: flip.tokenIdentifier,
                        nonce: flip.tokenNonce,
                        amount: profitIfWin
                    )
            }
        } else {
            storageController.getTokenReserve(
                tokenIdentifier: flip.tokenIdentifier,
                tokenNonce: flip.tokenNonce
            )
            .update { $0 = $0 + profitIfWin }
        }
        
        storageController.$flipForId[flip.id].clear()
    }
}
