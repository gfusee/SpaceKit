import SpaceKit

@Codable public struct NonceAmountMappingKey {
    let identifier: TokenIdentifier
    let nonce: UInt64
}

struct Storage {
    @Mapping<TokenIdentifier, TokenOwnershipData>(key: "token_details") var tokenDetailsForTokenIdentifier
    @Mapping<TokenIdentifier, Buffer>(key: "bonding_curve") var bondingCurveForTokenIdentifier
    @Mapping<NonceAmountMappingKey, BigUint>(key: "nonce_amount") var nonceAmountForTokenIdentifierAndNonce
    
    func getOwnedTokensMapperForOwner(owner: Address) -> SetMapper<TokenIdentifier> {
        return SetMapper(baseKey: "owned_tokens") {
            owner
        }
    }
}
