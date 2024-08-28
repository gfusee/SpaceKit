import Space

struct SignatureOperationsModule {
    
    func withdraw(address: Address) {
        let depositMapper = StorageModule().$depositForDonor[address]
        
        require(
            !depositMapper.isEmpty(),
            "non-existent key"
        )
        
        let deposit = depositMapper.take()
        let paidFeeToken = deposit.fees.value
        
        let blockRound = Blockchain.getBlockRound()
        require(
            deposit.expirationRound < blockRound,
            "withdrawal has not been available yet"
        )
        
        var egldFunds = deposit.egldFunds
        var esdtFunds = deposit.esdtFunds
        
        if paidFeeToken.tokenIdentifier == "EGLD" { // TODO: no hardcoded EGLD
            egldFunds = egldFunds + paidFeeToken.amount
        } else {
            esdtFunds = esdtFunds.appended(
                TokenPayment.new(
                    tokenIdentifier: paidFeeToken.tokenIdentifier,
                    nonce: 0,
                    amount: paidFeeToken.amount
                )
            )
        }
        
        if egldFunds > 0 {
            deposit.depositorAddress.send(egldValue: egldFunds)
        }
        
        if !esdtFunds.isEmpty {
            deposit.depositorAddress.send(payments: esdtFunds)
        }
    }
    
    func claim(
        address: Address,
        signature: Buffer
    ) {
        let depositMapper = StorageModule().$depositForDonor[address]
        
        require(
            !depositMapper.isEmpty(),
            "non-existent key"
        )
        
        let caller = Message.caller
        self.requireSignature(
            address: address,
            callerAddress: caller,
            signature: signature
        )
        
        let blockRound = Blockchain.getBlockRound()
        let deposit = depositMapper.take()
        let numTokensTransfered = HelpersModule().getNumTokenTransfers(
            egldValue: deposit.egldFunds,
            esdtTransfers: deposit.esdtFunds
        )
        var depositedFee = deposit.fees.value
        
        let feeToken = depositedFee.tokenIdentifier
        let fee = StorageModule().feeForToken[feeToken]
        
        require(
            deposit.expirationRound >= blockRound,
            "deposit expired"
        )
        
        let feeCost = fee * BigUint(value: numTokensTransfered)
        depositedFee.amount = depositedFee.amount - feeCost
        
        let collectedFeesMapper = StorageModule().$collectedFeesForToken[feeToken]
        var currentCollectedFees = collectedFeesMapper.get()
        currentCollectedFees = currentCollectedFees + feeCost
        collectedFeesMapper.set(currentCollectedFees)
        
        if deposit.egldFunds > 0 {
            caller.send(egldValue: deposit.egldFunds)
        }
        
        if !deposit.esdtFunds.isEmpty {
            caller.send(payments: deposit.esdtFunds)
        }
        
        if depositedFee.amount > 0 {
            HelpersModule().sendFeeToAddress(
                fee: depositedFee,
                address: deposit.depositorAddress
            )
        }
    }
    
    func forward(
        address: Address,
        forwardAddress: Address,
        signature: Buffer
    ) {
        let paidFee = Message.egldOrSingleEsdtTransfer
        let caller = Message.caller
        let feeToken = paidFee.tokenIdentifier
        
        self.requireSignature(
            address: address,
            callerAddress: caller,
            signature: signature
        )
        
        HelpersModule().updateFees(
            callerAddress: caller,
            address: forwardAddress,
            payment: paidFee
        )
        
        let forwardDepositMapper = StorageModule().$depositForDonor[forwardAddress]
        let fee = StorageModule().feeForToken[feeToken]
        
        var currentDeposit = StorageModule().$depositForDonor[address].take()
        let numTokens = HelpersModule().getNumTokenTransfers(
            egldValue: currentDeposit.egldFunds,
            esdtTransfers: currentDeposit.esdtFunds
        )
        let numTokensBigUint = BigUint(value: numTokens)
        
        var forwardDeposit = forwardDepositMapper.get()
        
        require(
            forwardDeposit.egldFunds == 0 && forwardDeposit.esdtFunds.isEmpty,
            "key already used"
        )
        
        require(
            fee * numTokensBigUint <= forwardDeposit.fees.value.amount,
            "cannot deposit funds without covering the fee cost first"
        )
        
        forwardDeposit.fees.numTokenToTransfer = forwardDeposit.fees.numTokenToTransfer + UInt32(numTokens) // TODO: is this cast safe?
        forwardDeposit.valability = currentDeposit.valability
        forwardDeposit.expirationRound = HelpersModule().getExpirationRound(valability: currentDeposit.valability)
        forwardDeposit.esdtFunds = currentDeposit.esdtFunds
        forwardDeposit.egldFunds = currentDeposit.egldFunds
        
        forwardDepositMapper.set(forwardDeposit)
        
        let forwardFee = fee * numTokensBigUint
        currentDeposit.fees.value.amount = currentDeposit.fees.value.amount - forwardFee
        
        let collectedFeesMapper = StorageModule().$collectedFeesForToken[feeToken]
        var currentCollectedFees = collectedFeesMapper.get()
        currentCollectedFees = currentCollectedFees + forwardFee
        collectedFeesMapper.set(currentCollectedFees)
        
        if currentDeposit.fees.value.amount > 0 {
            HelpersModule().sendFeeToAddress(
                fee: currentDeposit.fees.value,
                address: currentDeposit.depositorAddress
            )
        }
    }
    
    func requireSignature(
        address: Address,
        callerAddress: Address,
        signature: Buffer
    ) {
        Crypto.verifyEd25519(
            key: address.buffer,
            message: callerAddress.buffer,
            signature: signature
        )
    }
}
