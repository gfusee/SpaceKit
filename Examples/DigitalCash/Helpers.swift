import SpaceKit

struct Helpers {
    func sendFeeToAddress(
        fee: TokenPayment,
        address: Address
    ) {
        if fee.tokenIdentifier.isEGLD {
            address.send(egldValue: fee.amount)
        } else {
            address.send(
                tokenIdentifier: fee.tokenIdentifier,
                nonce: 0,
                amount: fee.amount
            )
        }
    }
    
    func getNumTokenTransfers(
        egldValue: BigUint,
        esdtTransfers: Vector<TokenPayment>
    ) -> Int32 {
        var amount = esdtTransfers.count
        
        if egldValue > 0 {
            amount += 1
        }
        
        return amount
    }
    
    func getExpirationRound(valability: UInt64) -> UInt64 {
        let valabilityRounds = valability / SECONDS_PER_ROUND
        
        return Blockchain.getBlockRound() + valabilityRounds
    }
    
    func makeFunds(
        egldPayment: BigUint,
        esdtPayments: Vector<TokenPayment>,
        address: Address,
        valability: UInt64
    ) {
        let depositMapper = Storage().$depositForDonor[address]
        
        var currentDeposit = depositMapper.get()
        
        require(
            currentDeposit.egldFunds == 0 && currentDeposit.esdtFunds.isEmpty,
            "key already used"
        )
        
        let numTokens = self.getNumTokenTransfers(
            egldValue: egldPayment,
            esdtTransfers: esdtPayments
        )
        
        currentDeposit.fees.numTokenToTransfer += UInt32(numTokens)
        currentDeposit.valability = valability
        currentDeposit.expirationRound = self.getExpirationRound(valability: valability)
        currentDeposit.esdtFunds = esdtPayments
        currentDeposit.egldFunds = egldPayment
        
        depositMapper.set(currentDeposit)
    }
    
    func checkFeesCoverNumberOfTokens(
        numTokens: Int32,
        fee: BigUint,
        paidFee: BigUint
    ) {
        require(
            numTokens > 0,
            "amount must be greater than 0"
        )
        
        require(
            fee * BigUint(value: numTokens) <= paidFee,
            "cannot deposit funds without covering the fee cost first"
        )
    }
    
    func updateFees(
        callerAddress: Address,
        address: Address,
        payment: TokenPayment
    ) {
        let _ = self.getFeeForToken(token: payment.tokenIdentifier)
        let depositMapper = Storage().$depositForDonor[address]
        
        if !depositMapper.isEmpty() {
            var currentDeposit = depositMapper.get()
            
            require(
                currentDeposit.depositorAddress == callerAddress,
                "invalid depositor address"
            )
            
            require(
                currentDeposit.fees.value.tokenIdentifier == payment.tokenIdentifier,
                "can only have 1 type of token as fee"
            )
            
            currentDeposit.fees.value.amount = currentDeposit.fees.value.amount + payment.amount
            depositMapper.set(currentDeposit)
            
            return
        }
        
        let newDeposit = DepositInfo(
            depositorAddress: callerAddress,
            esdtFunds: Vector(),
            egldFunds: 0,
            valability: 0,
            expirationRound: 0,
            fees: Fee(numTokenToTransfer: 0, value: payment)
        )
        
        depositMapper.set(newDeposit)
    }
    
    func getFeeForToken(token: TokenIdentifier) -> BigUint {
        require(
            Storage().whitelistedFeeTokens.contains(value: token),
            "invalid fee token provided"
        )
        
        return Storage().feeForToken[token]
    }
    
}
