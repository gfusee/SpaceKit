import MultiversX

struct HelpersModule {
    
    func updateFees(
        callerAddress: Address,
        address: Address,
        payment: TokenPayment
    ) {
        let _ = self.getFeeForToken(token: payment.tokenIdentifier)
        let depositMapper = StorageModule().$depositForDonor[address]
        
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
            
            return
        }
        
        let newDeposit = DepositInfo(
            depositorAddress: callerAddress,
            esdtFunds: MXArray(),
            egldFunds: 0,
            valability: 0,
            expirationRound: 0,
            fees: Fee(numTokenToTransfer: 0, value: payment)
        )
        
        depositMapper.set(newDeposit)
    }
    
    func getFeeForToken(token: MXBuffer) -> BigUint {
        require(
            StorageModule().whitelistedFeeTokens.contains(value: token),
            "invalid fee token provided"
        )
        
        return StorageModule().feeForToken[token]
    }
    
}
