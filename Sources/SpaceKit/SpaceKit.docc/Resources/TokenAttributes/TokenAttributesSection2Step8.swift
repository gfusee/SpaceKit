import SpaceKit

@Codable public struct LockedTokenAttributes {
    let creationTimestamp: UInt64
    let lockDuration: UInt64
    let lockedEgldAmount: BigUint
}

@Init public func initialize(
    tokenIdentifier: Buffer,
    lockDuration: UInt64
) {
    var controller = MyContract()
    
    controller.tokenIdentifier = tokenIdentifier
    controller.lockDuration = lockDuration
}

@Controller struct LockController {
    @Storage(key: "tokenIdentifier") var tokenIdentifier: Buffer
    @Storage(key: "lockDuration") var lockDuration: UInt64
    
    public func lockFunds() -> UInt64 {
        let tokenRoles = Blockchain.getESDTLocalRoles(tokenIdentifier: self.tokenIdentifier)
        
        guard tokenRoles.contains(flag: .nftCreate) else {
            smartContractError(message: "Cannot create new NFT")
        }
        
        let paymentAmount = Message.egldValue
        
        guard paymentAmount > 0 else {
            smartContractError(message: "EGLD payment should be greater than zero")
        }
        
        let lockedAttributes = LockedTokenAttributes(
            creationTimestamp: Blockchain.getBlockTimestamp(),
            lockDuration: self.lockDuration,
            lockedEgldAmount: paymentAmount
        )
        
        let newNonce = Blockchain
            .createNft(
                tokenIdentifier: self.tokenIdentifier,
                amount: 1,
                name: "LockedEGLD",
                royalties: 0,
                hash: "",
                attributes: lockedAttributes,
                uris: Vector()
            )
        
        Message.caller
            .send(
                tokenIdentifier: self.tokenIdentifier,
                nonce: newNonce,
                amount: 1
            )
        
        return newNonce
    }
    
    public func unlockFunds() -> BigUint {
        let tokenRoles = Blockchain.getESDTLocalRoles(tokenIdentifier: self.tokenIdentifier)
        
        guard tokenRoles.contains(flag: .nftBurn) else {
            smartContractError(message: "Cannot burn NFT")
        }
        
        let payment = Message.singleEsdt
        
        guard payment.tokenIdentifier == self.tokenIdentifier else {
            smartContractError(message: "Wrong payment")
        }
        
        let attributes = self.getTokenAttributes(nonce: payment.nonce)
        
        let unlockTime = attributes.creationTimestamp + attributes.lockDuration
        
        guard Blockchain.getBlockTimestamp() >= unlockTime else {
            smartContractError(message: "Funds cannot be unlocked yet")
        }
    }
    
    func getTokenAttributes(nonce: UInt64) -> LockedTokenAttributes {
        Blockchain
            .getTokenAttributes(
                tokenIdentifier: self.tokenIdentifier,
                nonce: nonce
            )
    }
}

