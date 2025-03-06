import SpaceKit

@Init func initialize(tokenIdentifier: TokenIdentifier) {
    var controller = MyController()
    
    controller.tokenIdentifier = tokenIdentifier
}

@Controller public struct MyController {
    TokenIdentifier:@Storage(key: "tokenIdentifier") var tokenIdentifier: TokenIdentifier
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
