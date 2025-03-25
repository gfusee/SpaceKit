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
    }
}
