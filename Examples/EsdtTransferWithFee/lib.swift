import Space

@Codable struct PaidFeesMapperKey {
    let tokenIdentifier: MXBuffer
    let nonce: UInt64
}

@Contract struct EsdtTransferWithFee {
    
    @Mapping<MXBuffer, Fee>(key: "token_fee") var tokenFeeForToken
    
    // TODO: use TokenIdentifier type
    public mutating func setExactValueFee(
        feeToken: MXBuffer,
        feeAmount: BigUint,
        token: MXBuffer
    ) {
        assertOwner()
        
        self.tokenFeeForToken[token] = Fee.exactValue(
            TokenPayment.new(
                tokenIdentifier: feeToken,
                nonce: 0,
                amount: feeAmount
            )
        )
    }
    
    // TODO: use TokenIdentifier type
    public mutating func setPercentageFee(
        fee: UInt32,
        token: MXBuffer
    ) {
        assertOwner()
        
        self.tokenFeeForToken[token] = Fee.percentage(fee)
    }
    
    public mutating func claimFees() {
        assertOwner()
        
        let paidFeesMapper = self.getPaidFeesMapper()
        var fees: MXArray<TokenPayment> = MXArray()
        
        paidFeesMapper.forEach { key, amount in
            fees = fees.appended(
                TokenPayment.new(
                    tokenIdentifier: key.tokenIdentifier,
                    nonce: key.nonce,
                    amount: amount
                )
            )
        }
        
        paidFeesMapper.clear()
        
        Message.caller.send(payments: fees)
    }
    
    public func transfer(address: Address) {
        require(
            Message.egldValue == 0,
            "EGLD transfers not allowed"
        )
        
        let payments = Message.allEsdtTransfers
        var newPayments: MXArray<TokenPayment> = MXArray()
        
        let paymentsCount = payments.count
        var index: Int32 = 0
        
        while index < paymentsCount {
            let payment = payments[index]
            let feeType = self.tokenFeeForToken[ifPresent: payment.tokenIdentifier] ?? .unset
            
            switch feeType {
            case .unset:
                newPayments = newPayments.appended(payment)
            case .exactValue(let fee):
                index += 1
                
                require(
                    index < paymentsCount,
                    "Fee payment missing"
                )
                
                let nextPayment = payments[index]
                require(
                    nextPayment.tokenIdentifier == fee.tokenIdentifier && nextPayment.nonce == fee.nonce,
                    "Fee payment missing"
                )
                
                require(
                    nextPayment.amount == fee.amount,
                    "Mismatching payment for covering fees"
                )
                
                let _ = self.getPaymentAfterFees(fee: feeType, payment: nextPayment)
                newPayments = newPayments.appended(payment)
            case .percentage(_):
                newPayments = newPayments.appended(self.getPaymentAfterFees(fee: feeType, payment: payment))
            }
            
            index += 1
        }
        
        address.send(payments: newPayments)
    }
    
    func getPaymentAfterFees(
        fee: Fee,
        payment: TokenPayment
    ) -> TokenPayment {
        var newPayment = payment
        let feePayment = self.calculateFee(fee: fee, provided: payment)
        
        let paidFeesMapper = self.getPaidFeesMapper()
        let key = PaidFeesMapperKey(tokenIdentifier: newPayment.tokenIdentifier, nonce: newPayment.nonce)
        var paidFees = paidFeesMapper.get(key) ?? 0
        paidFees = paidFees + feePayment.amount
        let _ = paidFeesMapper.insert(key: key, value: paidFees)
        
        newPayment.amount = newPayment.amount - feePayment.amount
        return newPayment
    }
    
    func calculateFee(
        fee: Fee,
        provided: TokenPayment
    ) -> TokenPayment {
        var provided = provided
        
        switch fee {
        case .unset:
            provided.amount = 0
        case .exactValue(let requested):
            provided = requested
        case .percentage(let percentage):
            let calculatedFeeAmount = provided.amount * BigUint(value: percentage) / BigUint(value: PERCENTAGE_DIVISOR)
            provided.amount = calculatedFeeAmount
        }
        
        return provided
    }
    
    func getPaidFeesMapper() -> MapMapper<PaidFeesMapperKey, BigUint> {
        return MapMapper(baseKey: "paid_fees")
    }
    
}
