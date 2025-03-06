import SpaceKit

@Init func initialize(tokenIdentifier: TokenIdentifier) {
    var controller = MyController()
    
    controller.tokenIdentifier = tokenIdentifier
}

@Controller public struct MyController {
    @Storage(key: "tokenIdentifier") var tokenIdentifier: TokenIdentifier
    @Mapping<Address, BigUint>(key: "depositedTokens") var depositedTokensForAddress
}
