import SpaceKit

let HUNDRED_PERCENT: UInt64 = 100_000

@Controller public struct GameController {
    public func flip() {
        let payment = Message.singleEsdt
        
        let tokenReserve = StorageController()
            .getTokenReserve(
                tokenIdentifier: payment.tokenIdentifier,
                tokenNonce: payment.nonce
            )
            .get()
        
        let maximumBet = StorageController()
            .getMaximumBet(
                tokenIdentifier: payment.tokenIdentifier,
                tokenNonce: payment.nonce
            )
            .get()
        
        let maximumBetPercent = StorageController()
            .getMaximumBetPercent(
                tokenIdentifier: payment.tokenIdentifier,
                tokenNonce: payment.nonce
            )
            .get()

        let maximumBetPercentComputed = tokenReserve * BigUint(value: maximumBetPercent) / BigUint(value: HUNDRED_PERCENT)
        let maximumAllowedBet =
    }
}
