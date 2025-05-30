import SpaceKit

@Codable public struct LockedTokenAttributes {
    let creationTimestamp: UInt64
    var lockDuration: UInt64
    let lockedEgldAmount: BigUint
}

@Init public func initialize(
    tokenIdentifier: TokenIdentifier,
    lockDuration: UInt64
) {
    var controller = LockController()
    
    controller.tokenIdentifier = tokenIdentifier
    controller.lockDuration = lockDuration
}

@Controller public struct LockController {
    @Storage(key: "tokenIdentifier") var tokenIdentifier: TokenIdentifier
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
    }
}

