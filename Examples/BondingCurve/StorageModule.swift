import Space

// TODO: use TokenIdentifier type once implemented
@Codable struct NonceAmountMappingKey {
    let identifier: Buffer
    let nonce: UInt64
}

struct StorageModule {
    // TODO: use TokenIdentifier type once implemented
    @Mapping<Buffer, TokenOwnershipData>(key: "token_details") static var tokenDetailsForTokenIdentifier
    // TODO: use TokenIdentifier type once implemented
    @Mapping<Buffer, Buffer>(key: "bonding_curve") static var bondingCurveForTokenIdentifier
    @Mapping<NonceAmountMappingKey, BigUint>(key: "nonce_amount") static var nonceAmountForTokenIdentifierAndNonce
    
    // TODO: use TokenIdentifier type once implemented
    static func getOwnedTokensMapperForOwner(owner: Address) -> SetMapper<Buffer> {
        return SetMapper(baseKey: "owned_tokens") {
            owner
        }
    }
}
