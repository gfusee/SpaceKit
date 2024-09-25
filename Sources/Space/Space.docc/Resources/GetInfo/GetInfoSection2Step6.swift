import Space

let secondsInADay: UInt64 = 86_400

@Contract struct MyContract {
    @Storage(key: "tokenIdentifier") var tokenIdentifier: Buffer
    @Mapping<Address, UInt64>(key: "lastDepositTime") var lastDepositTimeForAddress
    @Mapping<Address, BigUint>(key: "depositedTokens") var depositedTokensForAddress
    
    init(tokenIdentifier: Buffer) {
        self.tokenIdentifier = tokenIdentifier
    }
    
    public mutating func deposit() {
        let caller = Message.caller
        let payment = Message.singleFungibleEsdt
        
        guard payment.tokenIdentifier == self.tokenIdentifier else {
            smartContractError(message: "Wrong payment provided")
        }
        
        let currentTime = Blockchain.getBlockTimestamp()
        let callerLastDepositTime = self.lastDepositTimeForAddress[caller]
        let nextAllowedTime = callerLastDepositTime + secondsInADay
        
        self.depositedTokensForAddress[caller] = self.depositedTokensForAddress[caller] + payment.amount
    }
}
