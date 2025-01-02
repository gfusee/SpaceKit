import SpaceKit

let NFT_AMOUNT: UInt32 = 1
let ROYALTIES_MAX: UInt32 = 10_000

@Controller public struct NftController {
    @Storage(key: "nftTokenId") var nftTokenId: Buffer // TODO: use TokenIdentifier type once implemented
    @Mapping<UInt64, PriceTag>(key: "priceTag") var priceTagForNftNonce
    
    public mutating func createNft(
        name: Buffer,
        royalties: BigUint,
        uri: Buffer,
        sellingPrice: BigUint,
        optTokenUsedAsPayment: OptionalArgument<Buffer>,
        optTokenUsedAsPaymentNonce: OptionalArgument<UInt64>
    ) {
        assertOwner()
        
        let tokenUsedAsPayment: Buffer = if let tokenUsedAsPayment = optTokenUsedAsPayment.intoOptional() {
            tokenUsedAsPayment
        } else {
            "EGLD" // TODO: no hardcoded EGLD
        }
        
        // TODO: add a require that checks the token identifier is valid
        
        let tokenUsedAsPaymentNonce: UInt64 = if tokenUsedAsPayment == "EGLD" { // TODO: no hardcoded EGLD
            0
        } else {
            optTokenUsedAsPaymentNonce.intoOptional() ?? 0
        }
        
        let attributes = ExampleAttributes(creationTimestamp: Blockchain.getBlockTimestamp())
        
        let _ = self.createNftWithAttributes(
            name: name,
            royalties: royalties,
            attributes: attributes,
            uri: uri,
            sellingPrice: sellingPrice,
            tokenUsedAsPayment: tokenUsedAsPayment,
            tokenUsedAsPaymentNonce: tokenUsedAsPaymentNonce
        )
    }
    
    public func buyNft(nftNonce: UInt64) {
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
    
    private func issueToken(
        tokenName: Buffer,
        tokenTicker: Buffer
    ) {
        require(
            self.$nftTokenId.isEmpty(),
            "Token already issued"
        )
        
        let paymentAmount = Message.egldValue
        let gasForCallback: UInt64 = 20_000_000
        let gas = Blockchain.getGasLeft() - gasForCallback
        
        Blockchain.issueNonFungibleToken(
            tokenDisplayName: tokenName,
            tokenTicker: tokenTicker,
            properties: NonFungibleTokenProperties(
                canFreeze: true,
                canWipe: true,
                canPause: true,
                canTransferCreateRole: true,
                canChangeOwner: false,
                canUpgrade: false,
                canAddSpecialRoles: true
            )
        )
        .registerPromiseRaw(
            gas: gas,
            value: paymentAmount, // issue cost
            callbackName: "issueCallback", // TODO: handle $ callbacks in multi-file projects
            callbackArgs: ArgBuffer(),
            gasForCallback: gasForCallback
        )
    }
    
    private func setLocalRoles() {
        self.requireTokenIssued()
        
        Blockchain.setTokenRoles(
            for: Blockchain.getSCAddress(),
            tokenIdentifier: self.nftTokenId,
            roles: EsdtLocalRoles(
                canCreateNft: true
            )
        )
        .registerPromiseRaw(
            gas: Blockchain.getGasLeft()
        )
    }
    
    private mutating func createNftWithAttributes(
        name: Buffer,
        royalties: BigUint,
        attributes: ExampleAttributes,
        uri: Buffer,
        sellingPrice: BigUint,
        tokenUsedAsPayment: Buffer,
        tokenUsedAsPaymentNonce: UInt64
    ) -> UInt64 {
        self.requireTokenIssued()
        
        require(
            royalties <= BigUint(value: ROYALTIES_MAX),
            "Royalties cannot exceed 100%"
        )
        
        let nftTokenId = self.nftTokenId
        
        var serializedAttributes = Buffer()
        attributes.topEncode(output: &serializedAttributes)
        
        let attributesHash = Crypto.getSha256Hash(of: serializedAttributes)
        let uris = Vector(singleItem: uri)
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
    
    private func requireTokenIssued() {
        require(
            !self.$nftTokenId.isEmpty(),
            "Token not issued"
        )
    }
    
    @Callback public mutating func issueCallback() {
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
