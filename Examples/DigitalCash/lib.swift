import SpaceKit

@Init func initialize(fee: BigUint, token: Buffer) {
    let controller = DigitalCash()
    
    controller.whitelistFeeTokenLogic(fee: fee, token: token)
}

@Contract struct DigitalCash {
    public func payFeeAndFundESDT(
        address: Address,
        valability: UInt64
    ) {
        PayFeeAndFundModule().payFeeAndFundESDT(address: address, valability: valability)
    }
    
    public func payFeeAndFundEGLD(
        address: Address,
        valability: UInt64
    ) {
        PayFeeAndFundModule().payFeeAndFundEGLD(address: address, valability: valability)
    }
    
    public func fund(
        address: Address,
        valability: UInt64
    ) {
        PayFeeAndFundModule().fund(address: address, valability: valability)
    }
    
    public func depositFees(address: Address) {
        PayFeeAndFundModule().depositFees(address: address)
    }
    
    public func withdraw(address: Address) {
        SignatureOperationsModule().withdraw(address: address)
    }
    
    public func claim(
        address: Address,
        signature: Buffer
    ) {
        SignatureOperationsModule().claim(address: address, signature: signature)
    }
    
    public func forward(
        address: Address,
        forwardAddress: Address,
        signature: Buffer
    ) {
        SignatureOperationsModule().forward(address: address, forwardAddress: forwardAddress, signature: signature)
    }
    
    public mutating func whitelistFeeToken(
        fee: BigUint,
        token: Buffer
    ) {
        assertOwner()
        
        self.whitelistFeeTokenLogic(fee: fee, token: token)
    }
    
    public mutating func blacklistFeeToken(
        token: Buffer
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
        var collectedEsdtFees: Vector<TokenPayment> = Vector()
        
        feeTokensMapper.forEach { token in
            let fee = StorageModule().$collectedFeesForToken[token].take()
            
            guard fee > 0 else {
                return
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
        token: Buffer,
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
        token: Buffer
    ) {
        let feeForTokenMapper = StorageModule().$feeForToken[token]
        
        require(
            feeForTokenMapper.isEmpty(),
            "Token already whitelisted"
        )
        
        feeForTokenMapper.set(fee)
        
        let _ = StorageModule().whitelistedFeeTokens.insert(value: token)
        let _ = StorageModule().allTimeFeeTokens.insert(value: token)
    }
}
