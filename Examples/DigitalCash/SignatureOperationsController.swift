import SpaceKit

@Controller public struct SignatureOperationsController {
    public func withdraw(address: Address) {
        let depositMapper = Storage().$depositForDonor[address]
        
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
        
        if paidFeeToken.tokenIdentifier.isEGLD {
            egldFunds = egldFunds + paidFeeToken.amount
        } else {
            esdtFunds = esdtFunds.appended(
                TokenPayment(
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
    
    public func claim(
        address: Address,
        signature: Buffer
    ) {
        let depositMapper = Storage().$depositForDonor[address]
        
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
        let numTokensTransfered = Helpers().getNumTokenTransfers(
            egldValue: deposit.egldFunds,
            esdtTransfers: deposit.esdtFunds
        )
        var depositedFee = deposit.fees.value
        
        let feeToken = depositedFee.tokenIdentifier
        let fee = Storage().feeForToken[feeToken]
        
        require(
            deposit.expirationRound >= blockRound,
            "deposit expired"
        )
        
        let feeCost = fee * BigUint(value: numTokensTransfered)
        depositedFee.amount = depositedFee.amount - feeCost
        
        let collectedFeesMapper = Storage().$collectedFeesForToken[feeToken]
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
            Helpers().sendFeeToAddress(
                fee: depositedFee,
                address: deposit.depositorAddress
            )
        }
    }
    
    public func forward(
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
        
        Helpers().updateFees(
            callerAddress: caller,
            address: forwardAddress,
            payment: paidFee
        )
        
        let forwardDepositMapper = Storage().$depositForDonor[forwardAddress]
        let fee = Storage().feeForToken[feeToken]
        
        var currentDeposit = Storage().$depositForDonor[address].take()
        let numTokens = Helpers().getNumTokenTransfers(
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
        forwardDeposit.expirationRound = Helpers().getExpirationRound(valability: currentDeposit.valability)
        forwardDeposit.esdtFunds = currentDeposit.esdtFunds
        forwardDeposit.egldFunds = currentDeposit.egldFunds
        
        forwardDepositMapper.set(forwardDeposit)
        
        let forwardFee = fee * numTokensBigUint
        currentDeposit.fees.value.amount = currentDeposit.fees.value.amount - forwardFee
        
        let collectedFeesMapper = Storage().$collectedFeesForToken[feeToken]
        var currentCollectedFees = collectedFeesMapper.get()
        currentCollectedFees = currentCollectedFees + forwardFee
        collectedFeesMapper.set(currentCollectedFees)
        
        if currentDeposit.fees.value.amount > 0 {
            Helpers().sendFeeToAddress(
                fee: currentDeposit.fees.value,
                address: currentDeposit.depositorAddress
            )
        }
    }
    
    private func requireSignature(
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
