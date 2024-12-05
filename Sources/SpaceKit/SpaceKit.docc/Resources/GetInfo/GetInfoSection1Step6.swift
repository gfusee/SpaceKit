import SpaceKit

@Controller struct MyContract {
    @Storage(key: "tokenIdentifier") var tokenIdentifier: Buffer
    @Mapping<Address, BigUint>(key: "depositedTokens") var depositedTokensForAddress
    
    init(tokenIdentifier: Buffer) {
        self.tokenIdentifier = tokenIdentifier
    }
    
    public mutating func deposit() {
        let caller = Message.caller
    }
}
