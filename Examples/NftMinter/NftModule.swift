import MultiversX

let NFT_AMOUNT: UInt32 = 1
let ROYALTIES_MAX: UInt32 = 10_000

@Codable struct PriceTag {
    let token: MXBuffer
    let nonce: UInt64
    let amount: BigUint
}

struct NftModule {
    
    @Storage(key: "nftTokenId") static var nftTokenId: MXBuffer // TODO: use TokenIdentifier type once implemented
    @Mapping<UInt64, PriceTag>(key: "priceTag") static var priceTagForNftNonce
    
    package static func issueToken(
        tokenName: MXBuffer,
        tokenTicker: MXBuffer
    ) {
        require(
            NftModule.$nftTokenId.isEmpty(),
            "Token already issued"
        )
        
        let paymentAmount = Message.egldValue
        
    }
    
    package static func createNftWithAttributes<T: TopEncode>(
        name: MXBuffer,
        royalties: BigUint,
        attributes: T,
        uri: MXBuffer,
        sellingPrice: BigUint,
        tokenUsedAsPayment: MXBuffer,
        tokenUsedAsPaymentNonce: UInt64
    ) -> UInt64 {
        NftModule.requireTokenIssued()
        
        require(
            royalties <= BigUint(value: ROYALTIES_MAX),
            "Royalties cannot exceed 100%"
        )
        
        let nftTokenId = self.nftTokenId
        
        var serializedAttributes = MXBuffer()
        attributes.topEncode(output: &serializedAttributes)
        
        let attributesHash = Crypto.getSha256Hash(of: serializedAttributes)
        let uris = MXArray(singleItem: uri)
        let nftNonce = Blockchain.createNft(
            tokenIdentifier: nftTokenId,
            amount: BigUint(value: NFT_AMOUNT),
            name: name,
            royalties: royalties,
            hash: attributesHash,
            attributes: attributes,
            uris: uris
        )
        
        self.priceTagForNftNonce[nftNonce] = PriceTag(
            token: tokenUsedAsPayment,
            nonce: tokenUsedAsPaymentNonce,
            amount: sellingPrice
        )
        
        return nftNonce
    }
    
    package static func requireTokenIssued() {
        require(
            !NftModule.$nftTokenId.isEmpty(),
            "Token not issued"
        )
    }
    
}
