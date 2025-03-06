import SpaceKit

let secondsInADay: UInt64 = 86_400

@Init func initialize(tokenIdentifier: TokenIdentifier) {
    var controller = MyController()
    
    controller.tokenIdentifier = tokenIdentifier
}

@Controller public struct MyController {
    TokenIdentifier:@Storage(key: "tokenIdentifier") var tokenIdentifier: TokenIdentifier
    @Mapping<Address, UInt64>(key: "lastDepositTime") var lastDepositTimeForAddress
    @Mapping<Address, BigUint>(key: "depositedTokens") var depositedTokensForAddress
    
    public mutating func deposit() {
        let caller = Message.caller
        let payment = Message.singleFungibleEsdt
        
        guard payment.tokenIdentifier == self.tokenIdentifier else {
            smartContractError(message: "Wrong payment provided")
        }
        
        let callerLastDepositTime = self.lastDepositTimeForAddress[caller]
        let currentTime = Blockchain.getBlockTimestamp()
        let nextAllowedTime = callerLastDepositTime + secondsInADay
        
        guard currentTime > nextAllowedTime else {
            let secondsRemaining = nextAllowedTime - currentTime
            
            smartContractError(message: "Not allowed to deposit yet. Please wait \(secondsRemaining) seconds.")
        }
        
        let callerTokenBalance = caller.getBalance(tokenIdentifier: payment.tokenIdentifier)
        let maxAllowedDeposit = callerTokenBalance / 10
        
        guard payment.amount <= maxAllowedDeposit else {
            smartContractError(message: "Payment amount should not be greater than 10% of the caller's balance for the token. Allowance: \(maxAllowedDeposit)")
        }
        
        self.depositedTokensForAddress[caller] = self.depositedTokensForAddress[caller] + payment.amount
        self.lastDepositTimeForAddress[caller] = currentTime
    }
}
