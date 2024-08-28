import Space

let NFT_AMOUNT: UInt32 = 1
let ROYALTIES_MAX: UInt32 = 10_000

@Codable struct PriceTag {
    let token: Buffer
    let nonce: UInt64
    let amount: BigUint
}

struct NftModule {
    
    @Storage(key: "nftTokenId") static var nftTokenId: Buffer // TODO: use TokenIdentifier type once implemented
    @Mapping<UInt64, PriceTag>(key: "priceTag") static var priceTagForNftNonce
    
    package static func issueToken(
        tokenName: Buffer,
        tokenTicker: Buffer
    ) {
        require(
            NftModule.$nftTokenId.isEmpty(),
            "Token already issued"
        )
        
        let paymentAmount = Message.egldValue
        let gasForCallback: UInt64 = 20_000_000
        let gas = Blockchain.getGasLeft() - gasForCallback
        
        Blockchain.issueNonFungibleToken(
            tokenDisplayName: tokenName,
            tokenTicker: tokenTicker,
            properties: NonFungibleTokenProperties.new(
                canFreeze: true,
                canWipe: true,
                canPause: true,
                canTransferCreateRole: true,
                canChangeOwner: false,
                canUpgrade: false,
                canAddSpecialRoles: true
            )
        )
        .registerPromise(
            callbackName: "issueCallback",
            gas: gas,
            gasForCallback: gasForCallback,
            callbackArgs: ArgBuffer(),
            value: paymentAmount // issue cost
        )
    }
    
    package static func setLocalRoles() {
        self.requireTokenIssued()
        
        Blockchain.setTokenRoles(
            for: Blockchain.getSCAddress(),
            tokenIdentifier: self.nftTokenId,
            roles: EsdtLocalRoles(
                canCreateNft: true
            )
        )
        .registerPromise(
            callbackName: "", // TODO: no callback
            gas: Blockchain.getGasLeft(),
            gasForCallback: 0,
            callbackArgs: ArgBuffer()
        )
    }
    
    package static func buyNft(nftNonce: UInt64) {
        let payment = Message.egldOrSingleEsdtTransfer
        
        self.requireTokenIssued()
        
        let priceTagMapper = self.$priceTagForNftNonce[nftNonce]
        
        require(
            !priceTagMapper.isEmpty(),
            "Invalid nonce or NFT was already sold"
        )
        
        let priceTag = priceTagMapper.get()
        
        require(
            payment.tokenIdentifier == priceTag.token,
            "Invalid token used as payment"
        )
        require(
            payment.nonce == priceTag.nonce,
            "Invalid nonce for payment token"
        )
        require(
            payment.amount == priceTag.amount,
            "Invalid amount as payment"
        )
        
        priceTagMapper.clear()
        
        let nftTokenIdentifier = self.nftTokenId
        
        Message.caller
            .send(
                tokenIdentifier: nftTokenIdentifier,
                nonce: nftNonce,
                amount: BigUint(value: NFT_AMOUNT)
            )
        
        Blockchain.getOwner()
            .send(
                tokenIdentifier: payment.tokenIdentifier,
                nonce: payment.nonce,
                amount: payment.amount
            )
    }
    
    package static func createNftWithAttributes<T: TopEncode>(
        name: Buffer,
        royalties: BigUint,
        attributes: T,
        uri: Buffer,
        sellingPrice: BigUint,
        tokenUsedAsPayment: Buffer,
        tokenUsedAsPaymentNonce: UInt64
    ) -> UInt64 {
        NftModule.requireTokenIssued()
        
        require(
            royalties <= BigUint(value: ROYALTIES_MAX),
            "Royalties cannot exceed 100%"
        )
        
        let nftTokenId = self.nftTokenId
        
        var serializedAttributes = Buffer()
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
    
    package static func issueCallback() {
        let result: AsyncCallResult<Buffer> = Message.asyncCallResult() // TODO: use TokenIdentifier type once available
        
        switch result {
        case .success(let tokenIdentifier):
            self.nftTokenId = tokenIdentifier
        case .error(_):
            let returned = Message.egldOrSingleEsdtTransfer
            if returned.tokenIdentifier == "EGLD" && returned.amount > 0 { // TODO: no hardcoded EGLD
                Message.caller // TODO: Message.caller in a callback???
                    .send(egldValue: returned.amount)
            }
        }
    }
    
}
