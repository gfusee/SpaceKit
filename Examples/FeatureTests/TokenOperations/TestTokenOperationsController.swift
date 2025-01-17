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
        to: Address
    ) -> UInt64 {
        let nonce = Blockchain.createNft(
            tokenIdentifier: tokenIdentifier,
            amount: initialSupply,
            name: "NFT",
            royalties: 0,
            hash: "",
            attributes: Buffer(),
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
}
