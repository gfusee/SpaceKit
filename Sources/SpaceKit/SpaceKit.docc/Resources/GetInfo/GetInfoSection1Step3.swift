import SpaceKit

@Controller public struct MyController {
    TokenIdentifier:@Storage(key: "tokenIdentifier") var tokenIdentifier: TokenIdentifier
    @Mapping<Address, BigUint>(key: "depositedTokens") var depositedTokensForAddress
}
