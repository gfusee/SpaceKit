import MultiversX

@Contract struct DigitalCash {
    init(fee: BigUint, token: MXBuffer) {
        self.whitelistFeeToken(fee: fee, token: token)
    }
    
    public mutating func whitelistFeeToken(
        fee: BigUint,
        token: MXBuffer
    ) {
        assertOwner()
        
        let feeForTokenMapper = StorageModule().$feeForToken[token]
        
        require(
            feeForTokenMapper.isEmpty(),
            "Token already whitelisted"
        )
        
        feeForTokenMapper.set(fee)
        
        let _ = StorageModule().whitelistedFeeTokens.insert(value: token)
        let _ = StorageModule().allTimeFeeTokens.insert(value: token)
    }
    
    public mutating func blacklistFeeToken(
        token: MXBuffer
    ) {
        assertOwner()
        
        let feeForTokenMapper = StorageModule().$feeForToken[token]
        
        require(
            !feeForTokenMapper.isEmpty(),
            "Token is not whitelisted"
        )
        
        feeForTokenMapper.clear()
        let _ = StorageModule().whitelistedFeeTokens.swapRemove(value: token)
    }
    
    public mutating func claimFees() {
        assertOwner()
        
        let feeTokensMapper = StorageModule().allTimeFeeTokens
        let caller = Message.caller
        var collectedEsdtFees: MXArray<TokenPayment> = MXArray()
        
        for token in feeTokensMapper {
            let fee = StorageModule().$collectedFeesForToken[token].take()
            
            guard fee > 0 else {
                continue
            }
            
            if token == "EGLD" { // TODO: no hardcoded EGLD
                caller.send(egldValue: fee)
            } else {
                let collectedFee = TokenPayment.new(
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
        token: MXBuffer,
        nonce: UInt64
    ) -> BigUint {
        let depositMapper = StorageModule().$depositForDonor[address]
        
        require(
            !depositMapper.isEmpty(),
            "non-existent key"
        )
        
        let deposit = depositMapper.get()
        
        if token == "EGLD" { // TODO: no hardcoded EGLD
            return deposit.egldFunds
        }
        
        for esdt in deposit.esdtFunds {
            if esdt.tokenIdentifier == token && esdt.nonce == nonce {
                return esdt.amount
            }
        }
        
        return 0
    }
}
