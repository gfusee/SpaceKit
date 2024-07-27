import MultiversX

struct PayFeeAndFundModule {
    
    func payFeeAndFundESDT(
        address: Address,
        valability: UInt64
    ) {
        var payments = Message.allEsdtTransfers
        let fee = payments.get(0)
        let caller = Message.caller
        
        HelpersModule().updateFees(callerAddress: caller, address: address, payment: fee)
        
        payments = payments.removed(0)
        
        HelpersModule().makeFunds(egldPayment: 0, esdtPayments: payments, address: address, valability: valability)
    }
    
    func payFeeAndFundEGLD(
        address: Address,
        valability: UInt64
    ) {
        var fund = Message.egldValue
        let feeValue = StorageModule().feeForToken["EGLD"] // TODO: no hardcoded EGLD
        
        require(
            fund > feeValue,
            "payment not covering fees"
        )
        
        fund = fund - feeValue
        
        let fee = TokenPayment.new(
            tokenIdentifier: "EGLD", // TODO: no hardcoded EGLD
            nonce: 0,
            amount: feeValue
        )
        let caller = Message.caller
        
        HelpersModule().updateFees(callerAddress: caller, address: address, payment: fee)
        HelpersModule().makeFunds(egldPayment: fund, esdtPayments: MXArray(), address: address, valability: valability)
    }
    
    func fund(
        address: Address,
        valability: UInt64
    ) {
        let depositMapper = StorageModule().$depositForDonor[address]
        
        require(
            !depositMapper.isEmpty(),
            "fees not covered"
        )
        
        let deposit = depositMapper.get()
        
        require(
            deposit.depositorAddress == Message.caller,
            "invalid depositor"
        )
        
        let depositedFeeToken = deposit.fees.value
        let feeAmount = StorageModule().feeForToken[depositedFeeToken.tokenIdentifier]
        let egldPayment = Message.egldValue
        let esdtPayments = Message.allEsdtTransfers
        
        let numTokens = HelpersModule().getNumTokenTransfers(
            egldValue: egldPayment,
            esdtTransfers: esdtPayments
        )
        
        HelpersModule().checkFeesCoverNumberOfTokens(
            numTokens: numTokens,
            fee: feeAmount,
            paidFee: depositedFeeToken.amount
        )
        HelpersModule().makeFunds(
            egldPayment: egldPayment,
            esdtPayments: esdtPayments,
            address: address,
            valability: valability
        )
    }
    
    func depositFees(address: Address) {
        let payment = Message.egldValue
        let caller = Message.caller
        
        HelpersModule().updateFees(
            callerAddress: caller,
            address: address,
            payment: TokenPayment.new(
                tokenIdentifier: "EGLD", // TODO: no hardcoded EGLD
                nonce: 0,
                amount: payment
            )
        )
    }
}
