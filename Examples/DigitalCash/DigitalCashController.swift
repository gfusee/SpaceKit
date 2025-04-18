import SpaceKit

@Controller public struct DigitalCashController {
    public mutating func whitelistFeeToken(
        fee: BigUint,
        token: TokenIdentifier
    ) {
        assertOwner()
        
        self.whitelistFeeTokenLogic(fee: fee, token: token)
    }
    
    public mutating func blacklistFeeToken(
        token: TokenIdentifier
    ) {
        assertOwner()
        
        let feeForTokenMapper = Storage().$feeForToken[token]
        
        require(
            !feeForTokenMapper.isEmpty(),
            "Token is not whitelisted"
        )
        
        feeForTokenMapper.clear()
        let _ = Storage().whitelistedFeeTokens.swapRemove(value: token)
    }
    
    public mutating func claimFees() {
        assertOwner()
        
        let feeTokensMapper = Storage().allTimeFeeTokens
        let caller = Message.caller
        var collectedEsdtFees: Vector<TokenPayment> = Vector()
        
        for token in feeTokensMapper {
            let fee = Storage().$collectedFeesForToken[token].take()
            
            guard fee > 0 else {
                return
            }
            
            if token.isEGLD {
                caller.send(egldValue: fee)
            } else {
                let collectedFee = TokenPayment(
                    tokenIdentifier: token,
                    nonce: 0,
                    amount: fee
                )
                
                collectedEsdtFees = collectedEsdtFees.appended(collectedFee)
            }
        }
        
        if !collectedEsdtFees.isEmpty {
            caller.send(payments: collectedEsdtFees)
        }
    }

    public func getAmount(
        address: Address,
        token: TokenIdentifier,
        nonce: UInt64
    ) -> BigUint {
        let depositMapper = Storage().$depositForDonor[address]
        
        require(
            !depositMapper.isEmpty(),
            "non-existent key"
        )
        
        let deposit = depositMapper.get()
        
        if token.isEGLD {
            return deposit.egldFunds
        }
        
        for esdtIndex in 0..<deposit.esdtFunds.count {
            let esdt = deposit.esdtFunds.get(esdtIndex)
            
            if esdt.tokenIdentifier == token && esdt.nonce == nonce {
                return esdt.amount
            }
        }
        
        return 0
    }
    
    func whitelistFeeTokenLogic(
        fee: BigUint,
        token: TokenIdentifier
    ) {
        let feeForTokenMapper = Storage().$feeForToken[token]
        
        require(
            feeForTokenMapper.isEmpty(),
            "Token already whitelisted"
        )
        
        feeForTokenMapper.set(fee)
        
        let _ = Storage().whitelistedFeeTokens.insert(value: token)
        let _ = Storage().allTimeFeeTokens.insert(value: token)
    }
}
