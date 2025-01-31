import SpaceKit

@Controller public struct PayFeeAndFundController {
    public func payFeeAndFundESDT(
        address: Address,
        valability: UInt64
    ) {
        assertNoEgldPayment()
        
        var payments = Message.allEsdtTransfers
        let fee = payments.get(0)
        let caller = Message.caller
        
        Helpers().updateFees(callerAddress: caller, address: address, payment: fee)
        
        payments = payments.removed(0)
        
        Helpers().makeFunds(egldPayment: 0, esdtPayments: payments, address: address, valability: valability)
    }
    
    public func payFeeAndFundEGLD(
        address: Address,
        valability: UInt64
    ) {
        assertNoEsdtPayment()
        
        var fund = Message.egldValue
        let feeValue = Storage().feeForToken["EGLD"] // TODO: no hardcoded EGLD
        
        require(
            fund > feeValue,
            "payment not covering fees"
        )
        
        fund = fund - feeValue
        
        let fee = TokenPayment(
            tokenIdentifier: "EGLD", // TODO: no hardcoded EGLD
            nonce: 0,
            amount: feeValue
        )
        let caller = Message.caller
        
        Helpers().updateFees(callerAddress: caller, address: address, payment: fee)
        Helpers().makeFunds(egldPayment: fund, esdtPayments: Vector(), address: address, valability: valability)
    }
    
    public func fund(
        address: Address,
        valability: UInt64
    ) {
        let depositMapper = Storage().$depositForDonor[address]
        
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
        let feeAmount = Storage().feeForToken[depositedFeeToken.tokenIdentifier]
        let egldPayment = Message.egldValue
        let esdtPayments = Message.allEsdtTransfers
        
        let numTokens = Helpers().getNumTokenTransfers(
            egldValue: egldPayment,
            esdtTransfers: esdtPayments
        )
        
        Helpers().checkFeesCoverNumberOfTokens(
            numTokens: numTokens,
            fee: feeAmount,
            paidFee: depositedFeeToken.amount
        )
        Helpers().makeFunds(
            egldPayment: egldPayment,
            esdtPayments: esdtPayments,
            address: address,
            valability: valability
        )
    }
    
    public func depositFees(address: Address) {
        assertNoEsdtPayment()
        
        let payment = Message.egldValue
        let caller = Message.caller
        
        Helpers().updateFees(
            callerAddress: caller,
            address: address,
            payment: TokenPayment(
                tokenIdentifier: "EGLD", // TODO: no hardcoded EGLD
                nonce: 0,
                amount: payment
            )
        )
    }
}
