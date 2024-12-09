import SpaceKit

let secondsInADay: UInt64 = 86_400

@Init func initialize(tokenIdentifier: Buffer) {
    var controller = MyController()
    
    controller.tokenIdentifier = tokenIdentifier
}

@Controller struct MyController {
    @Storage(key: "tokenIdentifier") var tokenIdentifier: Buffer
    @Mapping<Address, UInt64>(key: "lastDepositTime") var lastDepositTimeForAddress
    @Mapping<Address, BigUint>(key: "depositedTokens") var depositedTokensForAddress
    
    public mutating func deposit() {
        let caller = Message.caller
        let payment = Message.singleFungibleEsdt
        
        guard payment.tokenIdentifier == self.tokenIdentifier else {
            smartContractError(message: "Wrong payment provided")
        }
        
        let currentTime = Blockchain.getBlockTimestamp()
        let callerLastDepositTime = self.lastDepositTimeForAddress[caller]
        let nextAllowedTime = callerLastDepositTime + secondsInADay
        
        guard currentTime > nextAllowedTime else {
            let secondsRemaining = nextAllowedTime - currentTime
            
            smartContractError(message: "Not allowed to deposit yet. Please wait \(secondsRemaining) seconds.")
        }
        
        self.depositedTokensForAddress[caller] = self.depositedTokensForAddress[caller] + payment.amount
    }
}
