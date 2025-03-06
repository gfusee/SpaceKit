import SpaceKit

@Controller public struct MyController {
    @Storage(key: "tokenIdentifier") var tokenIdentifier: TokenIdentifier
    @Mapping<Address, BigUint>(key: "depositedTokens") var depositedTokensForAddress
}
