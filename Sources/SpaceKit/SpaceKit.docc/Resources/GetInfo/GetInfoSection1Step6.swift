import SpaceKit

@Init func initialize(tokenIdentifier: Buffer) {
    var controller = MyController()
    
    controller.tokenIdentifier = tokenIdentifier
}

@Controller struct MyController {
    @Storage(key: "tokenIdentifier") var tokenIdentifier: Buffer
    @Mapping<Address, BigUint>(key: "depositedTokens") var depositedTokensForAddress
    
    public mutating func deposit() {
        let caller = Message.caller
    }
}
