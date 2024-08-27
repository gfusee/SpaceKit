import MultiversX

// TODO: use TokenIdentifier type once implemented
@Codable struct NonceAmountMappingKey {
    let identifier: MXBuffer
    let nonce: UInt64
}

struct StorageModule {
    // TODO: use TokenIdentifier type once implemented
    @Mapping<MXBuffer, TokenOwnershipData>(key: "token_details") static var tokenDetailsForTokenIdentifier
    // TODO: use TokenIdentifier type once implemented
    @Mapping<MXBuffer, MXBuffer>(key: "bonding_curve") static var bondingCurveForTokenIdentifier
    @Mapping<NonceAmountMappingKey, BigUint>(key: "nonce_amount") static var nonceAmountForTokenIdentifierAndNonce
    
    // TODO: Not dev friendly
    // TODO: use TokenIdentifier type once implemented
    static func getOwnedTokensMapperForOwner(owner: Address) -> SetMapper<MXBuffer> {
        var ownerSerialized = MXBuffer()
        owner.depEncode(dest: &ownerSerialized)
        
        return SetMapper(baseKey: "owned_tokens" + ownerSerialized)
    }
}
