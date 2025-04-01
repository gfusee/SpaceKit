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
    }
}
