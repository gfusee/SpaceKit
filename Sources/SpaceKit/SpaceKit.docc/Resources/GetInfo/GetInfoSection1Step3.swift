import SpaceKit

@Controller struct MyContract {
    @Storage(key: "tokenIdentifier") var tokenIdentifier: Buffer
    @Mapping<Address, BigUint>(key: "depositedTokens") var depositedTokensForAddress
}
