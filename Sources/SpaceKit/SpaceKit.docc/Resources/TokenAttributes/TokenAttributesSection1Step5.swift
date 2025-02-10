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
    }
}

