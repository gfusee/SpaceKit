import SpaceKit

let secondsInADay: UInt64 = 86_400

@Init func initialize(tokenIdentifier: Buffer) {
    var controller = MyController()
    
    controller.tokenIdentifier = tokenIdentifier
}

@Controller public struct MyController {
    @Storage(key: "tokenIdentifier") var tokenIdentifier: Buffer
    @Mapping<Address, UInt64>(key: "lastDepositTime") var lastDepositTimeForAddress
    @Mapping<Address, BigUint>(key: "depositedTokens") var depositedTokensForAddress
    
    public mutating func deposit() {
        let caller = Message.caller
        let payment = Message.singleFungibleEsdt
        
        guard payment.tokenIdentifier == self.tokenIdentifier else {
            smartContractError(message: "Wrong payment provided")
        }
        
        self.depositedTokensForAddress[caller] = self.depositedTokensForAddress[caller] + payment.amount
    }
}
