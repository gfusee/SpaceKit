import SpaceKit

@Controller public struct TestTokenOperationsController {
    public func mintTokens(
        tokenIdentifier: Buffer,
        nonce: UInt64,
        amount: BigUint,
        to: Address
    ) {
        Blockchain.mintTokens(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce,
            amount: amount
        )
        
        if to != Blockchain.getSCAddress() {
            to.send(
                tokenIdentifier: tokenIdentifier,
                nonce: nonce,
                amount: amount
            )
        }
    }
    
    public func createNFT(
        tokenIdentifier: Buffer,
        initialSupply: BigUint,
        royalties: BigUint,
        attributes: Buffer,
        to: Address
    ) -> UInt64 {
        let nonce = Blockchain.createNft(
            tokenIdentifier: tokenIdentifier,
            amount: initialSupply,
            name: "NFT",
            royalties: royalties,
            hash: "",
            attributes: attributes,
            uris: Vector()
        )
       
        if to != Blockchain.getSCAddress() {
            to.send(
                tokenIdentifier: tokenIdentifier,
                nonce: nonce,
                amount: initialSupply
            )
        }
        
        return nonce
    }
    
    public func burnTokens(
        tokenIdentifier: Buffer,
        nonce: UInt64,
        amount: BigUint
    ) {
        TokenPayment(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce,
            amount: amount
        ).burn()
    }
    
    public func modifyTokenRoyalties(
        tokenIdentifier: Buffer,
        nonce: UInt64,
        royalties: UInt64
    ) {
        Blockchain.modifyTokenRoyalties(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce,
            royalties: royalties
        )
    }
    
    public func getTokenRoyalties(
        tokenIdentifier: Buffer,
        nonce: UInt64
    ) -> BigUint {
        Blockchain.getTokenRoyalties(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce
        )
    }
    
    public func updateNftAttributes(
        tokenIdentifier: Buffer,
        nonce: UInt64,
        attributes: Buffer
    ) {
        Blockchain.updateNftAttributes(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce,
            attributes: attributes
        )
    }
    
    public func getTokenAttributes(
        tokenIdentifier: Buffer,
        nonce: UInt64
    ) -> Buffer {
        Blockchain.getTokenAttributes(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce
        )
    }
    
    public func doesAddressHaveSpecialRole(
        tokenIdentifier: Buffer,
        address: Address,
        expectedFlags: UInt64
    ) -> Bool {
        let roles = Blockchain.getESDTLocalRoles(tokenIdentifier: tokenIdentifier)
        
        return roles.flags == expectedFlags
    }
}
